/**
 * DFM KORBA OFFICIAL APP - AI QUIZ SERVICE
 * Gemini AI generation, teacher approval workflow, timed attempts & auto-grading.
 */

var QuizService = (function() {

  /**
   * Generate Quiz Questions with Gemini AI.
   */
  function generateQuestionsWithAI(user, data) {
    if (user.role !== 'TEACHER' && user.role !== 'ADMIN') {
      throw new Error("Only teachers or admins can trigger AI quiz generation.");
    }

    var props = PropertiesService.getScriptProperties();
    var apiKey = props.getProperty('GEMINI_API_KEY');

    var courseId = data.course_id || 'CRS_DRONE';
    var topic = data.topic || 'Drone Flight Rules & Cinematography Techniques';
    var count = Number(data.question_count) || 5;
    var difficulty = data.difficulty || 'INTERMEDIATE';

    var prompt = "You are an expert Drone Cinematography & Technical Skills instructor for DFM Korba. " +
      "Generate " + count + " quiz questions on the topic: '" + topic + "' for difficulty level: " + difficulty + ".\n" +
      "Return ONLY a valid JSON array of objects with NO markdown code fences or other text. " +
      "Each object must have the following keys:\n" +
      "- question_type: 'MCQ' or 'TRUE_FALSE' or 'FILL_BLANK'\n" +
      "- question_text: string\n" +
      "- option_a: string\n" +
      "- option_b: string\n" +
      "- option_c: string (or empty if TRUE_FALSE)\n" +
      "- option_d: string (or empty if TRUE_FALSE)\n" +
      "- correct_answer: 'A', 'B', 'C', 'D', 'TRUE', 'FALSE', or expected keyword\n" +
      "- explanation: brief 1-sentence reason\n" +
      "- marks: 2";

    var questions = [];

    if (apiKey) {
      try {
        var url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" + apiKey;
        var payload = {
          contents: [{
            parts: [{ text: prompt }]
          }]
        };
        var options = {
          method: "post",
          contentType: "application/json",
          payload: JSON.stringify(payload),
          muteHttpExceptions: true
        };
        var response = UrlFetchApp.fetch(url, options);
        var json = JSON.parse(response.getContentText());

        if (json.candidates && json.candidates[0] && json.candidates[0].content) {
          var rawText = json.candidates[0].content.parts[0].text;
          rawText = rawText.replace(/```json/g, '').replace(/```/g, '').trim();
          questions = JSON.parse(rawText);
        }
      } catch (e) {
        Logger.log("AI generation error: " + e.message);
      }
    }

    // High-quality fallback domain questions if Gemini API key not yet configured
    if (!questions || questions.length === 0) {
      questions = [
        {
          question_type: "MCQ",
          question_text: "According to DGCA India Drone Rules, what is the maximum permissible altitude for drone operations in the Green Zone without ATC clearance?",
          option_a: "200 feet (60 meters)",
          option_b: "400 feet (120 meters)",
          option_c: "500 feet (150 meters)",
          option_d: "1000 feet (300 meters)",
          correct_answer: "B",
          explanation: "In Indian Green Zones, flights up to 400 feet AGL are permitted without prior ATC permission.",
          marks: 2
        },
        {
          question_type: "MCQ",
          question_text: "Which camera gimbal move creates a cinematic 'Orbit Shot' around a subject?",
          option_a: "Flying straight up while tilting down",
          option_b: "Flying horizontally in a circle while yawing to keep subject centered",
          option_c: "Flying backwards through an obstacle",
          option_d: "Stationary hovering at 50% throttle",
          correct_answer: "B",
          explanation: "An orbit involves coordinated roll/yaw to trace a circumference around a focal point.",
          marks: 2
        },
        {
          question_type: "TRUE_FALSE",
          question_text: "Flying a drone near airports, military bases, and international borders without prior clearance is legal in India.",
          option_a: "TRUE",
          option_b: "FALSE",
          option_c: "",
          option_d: "",
          correct_answer: "FALSE",
          explanation: "These areas are classified as Red Zones requiring strict government authorization.",
          marks: 2
        },
        {
          question_type: "MCQ",
          question_text: "What shutter speed rule is standard for capturing natural cinematic motion blur at 24 fps?",
          option_a: "1/24 second",
          option_b: "1/48 or 1/50 second (180-degree shutter rule)",
          option_c: "1/500 second",
          option_d: "1/1000 second",
          correct_answer: "B",
          explanation: "The 180-degree rule dictates setting shutter speed to double the frame rate.",
          marks: 2
        },
        {
          question_type: "FILL_BLANK",
          question_text: "The Return To Home (RTH) failsafe activates automatically when drone ________ drops below critical threshold.",
          option_a: "Battery",
          option_b: "Propeller",
          option_c: "Payload",
          option_d: "Camera lens",
          correct_answer: "Battery",
          explanation: "Low battery voltage triggers the automated Return-To-Home safety procedure.",
          marks: 2
        }
      ];
    }

    return {
      course_id: courseId,
      topic: topic,
      questions: questions
    };
  }

  /**
   * Teacher approves questions and schedules the bi-weekly quiz.
   */
  function approveAndScheduleQuiz(user, data) {
    if (user.role !== 'TEACHER' && user.role !== 'ADMIN') {
      throw new Error("Only teachers or admins can schedule quizzes.");
    }

    var quizId = DatabaseService.generateId('QZ');
    var questions = data.questions || [];
    var totalMarks = 0;

    for (var i = 0; i < questions.length; i++) {
      totalMarks += Number(questions[i].marks) || 2;
    }

    var quiz = {
      quiz_id: quizId,
      title: data.title || 'Bi-Weekly Evaluation Quiz',
      course_id: data.course_id || 'CRS_DRONE',
      batch_id: data.batch_id || 'BTC_DFM_01',
      topic: data.topic || 'Curriculum Evaluation',
      source_material_id: data.source_material_id || '',
      total_questions: questions.length,
      duration_minutes: Number(data.duration_minutes) || 20,
      max_marks: totalMarks,
      pass_marks: Number(data.pass_marks) || Math.ceil(totalMarks * 0.5),
      start_window: data.start_window || new Date().toISOString(),
      end_window: data.end_window || new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString(),
      ai_generated: true,
      teacher_approved: true,
      approved_by: user.user_id,
      status: 'LIVE'
    };

    DatabaseService.insertRow('Quizzes', quiz);

    // Insert QuizQuestions
    var qRows = [];
    for (var j = 0; j < questions.length; j++) {
      var q = questions[j];
      qRows.push({
        question_id: DatabaseService.generateId('QQ'),
        quiz_id: quizId,
        question_type: q.question_type || 'MCQ',
        question_text: q.question_text,
        option_a: q.option_a || '',
        option_b: q.option_b || '',
        option_c: q.option_c || '',
        option_d: q.option_d || '',
        correct_answer: q.correct_answer || 'A',
        explanation: q.explanation || '',
        marks: Number(q.marks) || 2,
        order_index: j + 1
      });
    }

    if (qRows.length > 0) {
      DatabaseService.insertRowsBatch('QuizQuestions', qRows);
    }

    return {
      success: true,
      quiz_id: quizId,
      title: quiz.title,
      total_questions: questions.length,
      max_marks: totalMarks
    };
  }

  /**
   * Student submits quiz attempt with auto-grading.
   */
  function submitQuizAttempt(user, data) {
    var quizId = data.quiz_id;
    var quiz = DatabaseService.findRowByKey('Quizzes', 'quiz_id', quizId);
    if (!quiz) throw new Error("Quiz not found.");

    var questions = DatabaseService.findRows('QuizQuestions', function(q) {
      return q.quiz_id === quizId;
    });

    var questionMap = {};
    for (var i = 0; i < questions.length; i++) {
      questionMap[questions[i].question_id] = questions[i];
    }

    var answers = data.answers || []; // array of { question_id, answer }
    var scoreObtained = 0;
    var attemptId = DatabaseService.generateId('QA');
    var answerRows = [];

    for (var a = 0; a < answers.length; a++) {
      var ans = answers[a];
      var qObj = questionMap[ans.question_id];
      var isCorrect = false;
      var markAwarded = 0;

      if (qObj) {
        var cleanGiven = String(ans.answer).trim().toUpperCase();
        var cleanExpected = String(qObj.correct_answer).trim().toUpperCase();
        if (cleanGiven === cleanExpected) {
          isCorrect = true;
          markAwarded = Number(qObj.marks) || 2;
          scoreObtained += markAwarded;
        }
      }

      answerRows.push({
        answer_id: DatabaseService.generateId('QANS'),
        attempt_id: attemptId,
        question_id: ans.question_id,
        student_answer: ans.answer,
        is_correct: isCorrect,
        marks_awarded: markAwarded
      });
    }

    if (answerRows.length > 0) {
      DatabaseService.insertRowsBatch('QuizAnswers', answerRows);
    }

    var maxMarks = Number(quiz.max_marks) || 30;
    var pct = maxMarks > 0 ? ((scoreObtained / maxMarks) * 100).toFixed(1) : 0;
    var passed = scoreObtained >= Number(quiz.pass_marks);

    DatabaseService.insertRow('QuizAttempts', {
      attempt_id: attemptId,
      quiz_id: quizId,
      student_id: user.user_id,
      started_at: data.started_at || new Date().toISOString(),
      submitted_at: new Date().toISOString(),
      score_obtained: scoreObtained,
      percentage: Number(pct),
      passed: passed,
      status: 'COMPLETED'
    });

    // Record into IndividualMarks table
    var studentRecord = DatabaseService.findRowByKey('Students', 'user_id', user.user_id);
    var studentId = studentRecord ? studentRecord.student_id : user.user_id;

    DatabaseService.insertRow('IndividualMarks', {
      mark_id: DatabaseService.generateId('MRK_IND'),
      student_id: studentId,
      assessment_type: 'QUIZ',
      source_ref_id: quizId,
      max_marks: maxMarks,
      marks_obtained: scoreObtained,
      awarded_by: 'AI_AUTO_EVAL',
      feedback: 'Scored ' + scoreObtained + '/' + maxMarks + ' (' + pct + '%)'
    });

    TaskSubmissionService.updateStudentAggregates(studentId);

    return {
      attempt_id: attemptId,
      score_obtained: scoreObtained,
      max_marks: maxMarks,
      percentage: Number(pct),
      passed: passed,
      feedback: passed ? "Great job! You passed the quiz." : "Review course materials and try the next challenge."
    };
  }

  return {
    generateQuestionsWithAI: generateQuestionsWithAI,
    approveAndScheduleQuiz: approveAndScheduleQuiz,
    submitQuizAttempt: submitQuizAttempt
  };
})();
