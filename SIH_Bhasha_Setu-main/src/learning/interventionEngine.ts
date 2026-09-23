/**
 * Bhasha Setu Pedagogical Intervention Engine
 * Generates transparent, multi-step structured intervention prescriptions
 * combining digital scaffolding and teacher-led oral classroom prompts.
 */

import { FLNSkill, FLNDomain, DifficultyLevel, EvidenceLevel, StudentLearningProfile } from './types';
import { LearningActivityType } from './learningEvents';
import { getOutcomeForSkill } from './curriculum';

export interface InterventionStep {
  stepNumber: number;
  activityType: LearningActivityType;
  difficulty: DifficultyLevel;
  topic: string;
  title: string;
  description: string;
}

export interface PedagogicalIntervention {
  studentId: string;
  studentName: string;
  weakSkill: FLNSkill;
  domain: FLNDomain;
  evidence: {
    attempts: number;
    accuracy: number;
    level: EvidenceLevel;
  };
  reason: string;
  prescriptions: InterventionStep[];
  teacherLedOralPrompt: string;
  priority: 'critical' | 'high' | 'medium';
}

/**
 * Generates a structured multi-step intervention plan for a learner.
 */
export function generatePedagogicalIntervention(
  student: {
    studentId: string;
    name: string;
    grade: number;
    skills?: Record<string, { score: number; evidenceLevel?: EvidenceLevel; totalAttempts?: number }>;
    weakSkills?: FLNSkill[];
  },
  targetSkill?: FLNSkill
): PedagogicalIntervention | null {
  // Determine primary weak skill
  let skillToTarget: FLNSkill = targetSkill || 'vocabulary';
  let targetScore = 50;
  let attempts = 3;
  let evidenceLevel: EvidenceLevel = 'limited';

  if (student.skills) {
    const entries = Object.entries(student.skills);
    if (entries.length > 0) {
      const sorted = entries.sort((a, b) => a[1].score - b[1].score);
      const weakest = sorted[0];
      skillToTarget = targetSkill || (weakest[0] as FLNSkill);
      const metric = student.skills[skillToTarget] || weakest[1];
      targetScore = metric.score;
      attempts = metric.totalAttempts || 3;
      evidenceLevel = metric.evidenceLevel || 'limited';
    }
  }

  const outcome = getOutcomeForSkill(skillToTarget, student.grade);
  const domain: FLNDomain = (
    skillToTarget === 'numeracy' ||
    skillToTarget.startsWith('number_') ||
    skillToTarget === 'counting' ||
    skillToTarget === 'addition' ||
    skillToTarget === 'subtraction' ||
    skillToTarget === 'simple_word_problems'
  ) ? 'numeracy' : 'literacy';

  const defaultTopic = outcome?.targetCategories[0] || 'Classroom';
  const skillName = skillToTarget.replace(/_/g, ' ');

  // Determine severity and priority
  let priority: 'critical' | 'high' | 'medium' = 'medium';
  if (targetScore < 40 || evidenceLevel === 'insufficient') {
    priority = 'critical';
  } else if (targetScore < 60) {
    priority = 'high';
  }

  // Construct scaffolded digital practice steps
  const prescriptions: InterventionStep[] = [];

  if (skillToTarget === 'sentence_building') {
    prescriptions.push(
      {
        stepNumber: 1,
        activityType: 'matching',
        difficulty: 1,
        topic: defaultTopic,
        title: 'Vocabulary Reinforcement',
        description: 'Verify subject and verb tile recognition before sentence assembly.'
      },
      {
        stepNumber: 2,
        activityType: 'scramble',
        difficulty: 1,
        topic: defaultTopic,
        title: '3-Tile SOV Assembly',
        description: 'Reorder Subject-Object-Verb tiles in simple active declarative sentences.'
      },
      {
        stepNumber: 3,
        activityType: 'scramble',
        difficulty: 2,
        topic: defaultTopic,
        title: 'Connected Sentence Scramble',
        description: 'Construct full sentences with contextual adjectives or direct objects.'
      }
    );
  } else if (skillToTarget === 'reading' || skillToTarget === 'reading_comprehension') {
    prescriptions.push(
      {
        stepNumber: 1,
        activityType: 'flashcard',
        difficulty: 1,
        topic: defaultTopic,
        title: 'Sight Word Flashcard Review',
        description: 'Revisit core vocabulary pronunciation and Ol Chiki glyphs.'
      },
      {
        stepNumber: 2,
        activityType: 'matching',
        difficulty: 1,
        topic: defaultTopic,
        title: 'Phrase to Meaning Match',
        description: 'Match short 2-3 word Santali phrases with regional language definitions.'
      },
      {
        stepNumber: 3,
        activityType: 'mcq',
        difficulty: 2,
        topic: defaultTopic,
        title: 'Targeted Comprehension MCQ',
        description: 'Select the accurate meaning for short contextual expressions.'
      }
    );
  } else if (skillToTarget === 'script_recognition') {
    prescriptions.push(
      {
        stepNumber: 1,
        activityType: 'tracing',
        difficulty: 1,
        topic: defaultTopic,
        title: 'Guided Stroke Tracing',
        description: 'Trace Ol Chiki graphemes focusing on start-point and curvature.'
      },
      {
        stepNumber: 2,
        activityType: 'flashcard',
        difficulty: 1,
        topic: defaultTopic,
        title: 'Audio-Visual Flashcard Recall',
        description: 'Listen to letter-sound audio and confirm glyph identification.'
      },
      {
        stepNumber: 3,
        activityType: 'tracing',
        difficulty: 2,
        topic: defaultTopic,
        title: 'Freehand Grapheme Formation',
        description: 'Complete letter drawing without directional trace guides.'
      }
    );
  } else if (domain === 'numeracy') {
    prescriptions.push(
      {
        stepNumber: 1,
        activityType: 'flashcard',
        difficulty: 1,
        topic: 'Numbers',
        title: 'Numeral Recognition Drill',
        description: 'Practice Ol Chiki digits 1–20 with bilingual spoken audio.'
      },
      {
        stepNumber: 2,
        activityType: 'matching',
        difficulty: 1,
        topic: 'Numbers',
        title: 'Number-Quantity Pair Match',
        description: 'Match Ol Chiki digit cards with concrete visual count sets.'
      },
      {
        stepNumber: 3,
        activityType: 'mcq',
        difficulty: 2,
        topic: 'Numbers',
        title: 'Magnitude Comparison Check',
        description: 'Select the larger or smaller numeral in practical marketplace sets.'
      }
    );
  } else {
    // Default vocabulary intervention
    prescriptions.push(
      {
        stepNumber: 1,
        activityType: 'flashcard',
        difficulty: 1,
        topic: defaultTopic,
        title: '3D Audio Spaced Review',
        description: 'Review foundational vocabulary cards in active repetition queue.'
      },
      {
        stepNumber: 2,
        activityType: 'matching',
        difficulty: 1,
        topic: defaultTopic,
        title: 'Interactive Match the Pairs',
        description: 'Reinforce bilingual meaning pairs between Ol Chiki and regional languages.'
      },
      {
        stepNumber: 3,
        activityType: 'mcq',
        difficulty: 2,
        topic: defaultTopic,
        title: 'Distractor-Validated Quiz',
        description: 'Confirm stable lexical retention without visual support.'
      }
    );
  }

  // Teacher-led oral classroom prompt
  const teacherLedOralPrompt = domain === 'numeracy'
    ? `Engage ${student.name} in a 2-minute concrete counting circle: Ask the student to count physical stones or beads aloud in Santali, pointing to the Ol Chiki digit written on the board.`
    : `Conduct a 2-minute bilingual "Point and Say" exchange with ${student.name}: Point to classroom objects and prompt: "Santali te cet' ko meta?" encouraging full spoken phrase responses.`;

  const reason = `Learner demonstrated ${targetScore}% accuracy in ${skillName} across ${attempts} recent attempt(s) (${evidenceLevel} evidence). Scaffolded drill required to bridge foundational automaticity.`;

  return {
    studentId: student.studentId,
    studentName: student.name,
    weakSkill: skillToTarget,
    domain,
    evidence: {
      attempts,
      accuracy: targetScore,
      level: evidenceLevel
    },
    reason,
    prescriptions,
    teacherLedOralPrompt,
    priority
  };
}
