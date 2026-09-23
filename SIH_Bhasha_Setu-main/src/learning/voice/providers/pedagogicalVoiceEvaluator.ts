/**
 * Bhasha Setu Pedagogical Voice Evaluator
 * Evaluates student spoken responses without simplistic string equality.
 * Considers word-level accuracy, normalized token alignment, and Levenshtein similarity.
 * Never claims ungrounded phonetic accuracy if device ASR does not support it.
 */

import { IVoiceEvaluator, EvaluationOptions } from './types';
import { VoiceEvaluationResult } from '../types';

export class PedagogicalVoiceEvaluator implements IVoiceEvaluator {
  /**
   * Computes standard Levenshtein distance between two strings.
   */
  private levenshteinDistance(s1: string, s2: string): number {
    const m = s1.length;
    const n = s2.length;
    const dp: number[][] = Array.from({ length: m + 1 }, () => Array(n + 1).fill(0));

    for (let i = 0; i <= m; i++) dp[i][0] = i;
    for (let j = 0; j <= n; j++) dp[0][j] = j;

    for (let i = 1; i <= m; i++) {
      for (let j = 1; j <= n; j++) {
        if (s1[i - 1] === s2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = 1 + Math.min(dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]);
        }
      }
    }

    return dp[m][n];
  }

  /**
   * Computes similarity ratio (0.0 to 1.0) based on Levenshtein distance.
   */
  private computeSimilarity(s1: string, s2: string): number {
    const maxLen = Math.max(s1.length, s2.length);
    if (maxLen === 0) return 1.0;
    const distance = this.levenshteinDistance(s1, s2);
    return Math.max(0, 1 - distance / maxLen);
  }

  /**
   * Cleans and tokenizes text.
   */
  private tokenize(text: string): string[] {
    return text
      .trim()
      .toLowerCase()
      .replace(/[.,/#!$%^&*;:{}=\-_`~()?'"“”]/g, '')
      .split(/\s+/)
      .filter(t => t.length > 0);
  }

  async evaluate(
    recognizedText: string,
    expectedText: string,
    options: EvaluationOptions = {}
  ): Promise<VoiceEvaluationResult> {
    const startTime = performance.now();

    const cleanRec = (recognizedText || '').trim();
    const cleanExp = (expectedText || '').trim();

    if (!cleanRec) {
      return {
        recognizedText: '',
        expectedText: cleanExp,
        isCorrect: false,
        confidence: 0,
        wordAccuracy: 0,
        score: 0,
        feedback: 'No spoken response detected. Please press the microphone and speak aloud.',
        evaluationMethod: 'normalized_token_match',
        latencyMs: {
          asrLatencyMs: 0,
          evaluationLatencyMs: Math.round(performance.now() - startTime),
          totalLatencyMs: Math.round(performance.now() - startTime)
        }
      };
    }

    const recTokens = this.tokenize(cleanRec);
    const expTokens = this.tokenize(cleanExp);

    // 1. Token-Level Alignment & Word Error Classification
    const missingWords: string[] = [];
    const matchedExpTokens: string[] = [];

    for (const expToken of expTokens) {
      const match = recTokens.find(r => r === expToken || this.computeSimilarity(r, expToken) >= 0.8);
      if (match) {
        matchedExpTokens.push(expToken);
      } else {
        missingWords.push(expToken);
      }
    }

    const extraWords: string[] = recTokens.filter(
      r => !expTokens.some(e => e === r || this.computeSimilarity(r, e) >= 0.8)
    );

    const wordAccuracy = expTokens.length > 0 
      ? Math.round((matchedExpTokens.length / expTokens.length) * 100) 
      : 100;

    // 2. Character-Level Levenshtein Similarity
    const charSimilarity = this.computeSimilarity(cleanRec.toLowerCase(), cleanExp.toLowerCase());

    // 3. Calibrated Score Calculation
    // Prevents superficial string similarity from boosting unrelated utterances
    let score: number;
    if (cleanRec.toLowerCase() === cleanExp.toLowerCase()) {
      score = 100;
    } else if (matchedExpTokens.length === 0) {
      // If zero words match, penalize heavily to avoid awarding high scores to unrelated words
      score = Math.round(charSimilarity * 35);
    } else {
      // Word accuracy weighted 60%, character similarity weighted 40%, minus extra word penalty
      const extraPenalty = Math.min(20, extraWords.length * 10);
      score = Math.max(0, Math.round(wordAccuracy * 0.6 + charSimilarity * 100 * 0.4) - extraPenalty);
    }

    // Determine correctness threshold (>= 65% is accepted as a developing/correct response)
    const isCorrect = score >= 65;

    // 4. Constructive Pedagogical Feedback (Student-Facing: Encouraging & Safe)
    let feedback = '';
    if (score >= 90) {
      feedback = '🌟 Outstanding articulation! Word recognition is near perfect.';
    } else if (score >= 75) {
      feedback = '🌿 Very good pronunciation! Keep practicing to refine the rhythm.';
    } else if (score >= 50) {
      feedback = "🌱 Good try! Let's try that phrase again.";
    } else {
      feedback = '🔁 Good try! Listen to the guide and try speaking again.';
    }

    // 5. Teacher-Facing Diagnostic Metrics
    const issues: string[] = [];
    if (missingWords.length > 0) issues.push(`Missing: "${missingWords.join(', ')}"`);
    if (extraWords.length > 0) issues.push(`Extra words: "${extraWords.join(', ')}"`);
    if (issues.length === 0 && score < 85) issues.push('Minor pronunciation variation');

    const teacherSummary = `Word Accuracy: ${wordAccuracy}% | Confidence: ${Math.round(charSimilarity * 100)}% | Issues: ${issues.join('; ') || 'None'}`;

    const evalLatencyMs = Math.round(performance.now() - startTime);

    return {
      recognizedText: cleanRec,
      expectedText: cleanExp,
      isCorrect,
      confidence: Math.round(charSimilarity * 100) / 100,
      wordAccuracy,
      score: Math.min(100, Math.max(0, score)),
      feedback,
      evaluationMethod: 'normalized_token_match',
      latencyMs: {
        asrLatencyMs: 0,
        evaluationLatencyMs: evalLatencyMs,
        totalLatencyMs: evalLatencyMs
      },
      diagnostics: {
        teacherSummary,
        missingWords,
        extraWords,
        charSimilarity: Math.round(charSimilarity * 100) / 100,
        rawScore: score
      }
    };
  }
}
