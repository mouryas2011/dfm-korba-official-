/**
 * DFM KORBA OFFICIAL MOBILE APPLICATION
 * Local Mock Backend API Server (Native Node.js - Zero external dependencies)
 *
 * Runs on http://localhost:3000
 * Replicates all Google Apps Script doPost() and doGet() endpoints for instantaneous
 * local Flutter testing, CI/CD verification, and offline development.
 */

const http = require('http');
const PORT = process.env.PORT || 3000;

// In-memory mock database state
const mockDb = {
  users: {
    'admin': { role: 'ADMIN', name: 'System Administrator', phone: '9999999999', id: 'ADM_001', mustChangePassword: false },
    'teacher': { role: 'TEACHER', name: 'Rajesh Sharma', phone: '9827100000', id: 'TCH_001', mustChangePassword: false },
    '9827123456': { role: 'STUDENT', name: 'Aman Verma', phone: '9827123456', id: 'STU_DFM_001', mustChangePassword: false, course: 'CRS_DRONE', batch: 'BTC_DFM_01', team: 'TM_VEERVAAN' },
    'team': { role: 'TEAM', name: 'Team Veervaan', phone: '9827100002', id: 'TM_VEERVAAN', mustChangePassword: false, rank: 1, score: 485 }
  },
  chatMessages: [
    {
      message_id: 'MSG_001',
      channel_id: 'SQUAD_TM_VEERVAAN',
      channel_type: 'SQUAD',
      sender_id: 'STU_DFM_001',
      sender_name: 'Aman Verma',
      message_text: 'Hey team, I finished color grading the aerial sunset reel in Premiere Pro.',
      created_at: new Date(Date.now() - 3600000).toISOString()
    },
    {
      message_id: 'MSG_002',
      channel_id: 'SQUAD_TM_VEERVAAN',
      channel_type: 'SQUAD',
      sender_id: 'STU_DFM_002',
      sender_name: 'Priya Sharma',
      message_text: 'Awesome Aman! I verified the DGCA checklist for tomorrow morning flight.',
      created_at: new Date(Date.now() - 1800000).toISOString()
    }
  ]
};

function sendJson(res, statusCode, data) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With'
  });
  res.end(JSON.stringify(data));
}

const server = http.createServer((req, res) => {
  // CORS Preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With'
    });
    res.end();
    return;
  }

  // Health check / GET handler
  if (req.method === 'GET') {
    const url = new URL(req.url, `http://${req.headers.host}`);
    const action = url.searchParams.get('action');

    if (action === 'GET_PUBLIC_HOME_DATA' || url.pathname === '/public') {
      return sendJson(res, 200, {
        status: 'SUCCESS',
        code: 200,
        data: getPublicHomeData()
      });
    }

    return sendJson(res, 200, {
      status: 'SUCCESS',
      service: 'DFM_KORBA_MOCK_API',
      version: '1.0.0',
      database: 'Google Sheets Emulated',
      storage: 'Google Drive Emulated',
      aiEngine: 'Google Gemini 1.5 Flash Emulated',
      timestamp: new Date().toISOString()
    });
  }

  // POST Dispatcher
  if (req.method === 'POST') {
    let body = '';
    req.on('data', chunk => { body += chunk.toString(); });
    req.on('end', () => {
      let payload = {};
      try {
        payload = JSON.parse(body || '{}');
      } catch (e) {
        return sendJson(res, 400, { status: 'ERROR', message: 'Malformed JSON payload' });
      }

      const action = payload.action;
      console.log(`[DFM MOCK API] Action: ${action} | Time: ${new Date().toLocaleTimeString()}`);

      switch (action) {
        case 'LOGIN':
          return handleLogin(payload, res);

        case 'GET_PUBLIC_HOME_DATA':
          return sendJson(res, 200, { status: 'SUCCESS', code: 200, data: getPublicHomeData() });

        case 'GET_STUDENT_DASHBOARD':
          return sendJson(res, 200, {
            status: 'SUCCESS',
            code: 200,
            data: {
              student: { id: 'STU_DFM_001', name: 'Aman Verma', course: 'Drone Film Making', batch: 'DFM Batch 01', team: 'Veervaan' },
              progress_pct: 92.0,
              attendance_pct: 98.0,
              total_tasks: 12,
              completed_tasks: 10,
              total_quizzes: 5,
              today_task: {
                id: 'TSK_001',
                title: 'Drone Cinematic Shoot',
                course: 'Drone Film Making',
                due_date: '12 Nov 2026',
                max_marks: 100,
                type: 'TEAM_TASK'
              }
            }
          });

        case 'GET_TEACHER_DASHBOARD':
          return sendJson(res, 200, {
            status: 'SUCCESS',
            code: 200,
            data: {
              metrics: { batches_count: 4, students_count: 68, tasks_count: 12, competitions_count: 6 },
              batches: [{ id: 'BTC_DFM_01', name: 'DFM Batch 01', students: 24, course: 'Drone Film Making' }],
              pending_reviews_count: 3
            }
          });

        case 'GET_TEAM_DASHBOARD':
          return sendJson(res, 200, {
            status: 'SUCCESS',
            code: 200,
            data: {
              team_name: 'Veervaan',
              rank: 1,
              total_team_marks: 485,
              max_team_marks: 500,
              performance_pct: 97.0,
              tasks_count: 3,
              members_count: 6,
              members: [
                { id: 'STU_DFM_001', name: 'Aman Verma', role: 'Team Leader', contribution_pct: 22.0 },
                { id: 'STU_DFM_002', name: 'Priya Sharma', role: 'Camera Operator', contribution_pct: 18.0 },
                { id: 'STU_DFM_003', name: 'Rahul Soni', role: 'Gimbal Pilot', contribution_pct: 16.0 },
                { id: 'STU_DFM_004', name: 'Neha Gupta', role: 'Safety Observer', contribution_pct: 15.0 },
                { id: 'STU_DFM_005', name: 'Amit Dewangan', role: 'Editor', contribution_pct: 15.0 },
                { id: 'STU_DFM_006', name: 'Rohan Kumar', role: 'Sound Designer', contribution_pct: 14.0 }
              ]
            }
          });

        case 'GET_ADMIN_DASHBOARD':
          return sendJson(res, 200, {
            status: 'SUCCESS',
            code: 200,
            data: {
              courses_count: 8,
              teachers_count: 12,
              students_count: 248,
              teams_count: 28,
              system_health: 'OPTIMAL',
              active_quizzes: 4
            }
          });

        case 'UPLOAD_SUBMISSION_FILE':
          return sendJson(res, 200, {
            status: 'SUCCESS',
            code: 200,
            message: 'File successfully streamed and stored in Google Drive hierarchy',
            data: {
              submission_id: `SUB_${Date.now()}`,
              drive_file_id: `DRV_FL_${Math.random().toString(36).substring(2, 10)}`,
              file_name: payload.file_name || 'submission_file',
              status: 'PENDING_REVIEW'
            }
          });

        case 'SAVE_ATTENDANCE':
          return sendJson(res, 200, {
            status: 'SUCCESS',
            code: 200,
            message: 'Batch attendance roster successfully committed to Google Sheets AttendanceRecords table',
            synced_count: Array.isArray(payload.records) ? payload.records.length : 1
          });

        case 'SUBMIT_DAILY_REVIEW':
          return sendJson(res, 200, {
            status: 'SUCCESS',
            code: 200,
            message: 'Teacher Daily Company Review (8 mandatory fields) stored successfully in CompanyReviewReports table',
            review_id: `REV_${Date.now()}`
          });

        case 'GENERATE_AI_QUIZ_QUESTIONS':
          return sendJson(res, 200, {
            status: 'SUCCESS',
            code: 200,
            message: 'Gemini AI generated bi-weekly quiz questions awaiting teacher review',
            questions: [
              {
                id: 'QZ_GEN_001',
                question: 'What is the maximum permissible altitude for micro/small category drones in India as per DGCA Yellow/Green zones?',
                options: ['120 meters (400 ft) AGL', '200 meters AGL', '50 meters AGL', 'Unlimited'],
                correct_answer: '120 meters (400 ft) AGL',
                explanation: 'Under DGCA Drone Rules 2021, visual line-of-sight flights in green zones are capped at 400 ft (120 m) AGL.'
              },
              {
                id: 'QZ_GEN_002',
                question: 'When shooting cinematic 24fps video on a quadcopter with a 180-degree shutter rule, what shutter speed should be chosen?',
                options: ['1/50 sec', '1/200 sec', '1/1000 sec', '1/24 sec'],
                correct_answer: '1/50 sec',
                explanation: 'The 180-degree shutter rule dictates shutter speed = 1 / (2 * Frame Rate). For 24fps, standard cinema shutter is 1/48 or 1/50s.'
              },
              {
                id: 'QZ_GEN_003',
                question: 'Which neutral density (ND) filter reduces incoming sensor light by exactly 6 stops?',
                options: ['ND64', 'ND8', 'ND16', 'ND1000'],
                correct_answer: 'ND64',
                explanation: '2^6 = 64, therefore an ND64 filter provides a 6-stop optical light reduction.'
              }
            ]
          });

        case 'FETCH_CHAT_MESSAGES':
          return sendJson(res, 200, {
            status: 'SUCCESS',
            code: 200,
            messages: mockDb.chatMessages
          });

        case 'SEND_CHAT_MESSAGE':
          const newMsg = {
            message_id: `MSG_${Date.now()}`,
            channel_id: payload.channel_id || 'SQUAD_TM_VEERVAAN',
            channel_type: payload.channel_type || 'SQUAD',
            sender_id: payload.sender_id || 'STU_DFM_001',
            sender_name: payload.sender_name || 'Aman Verma',
            message_text: payload.message_text || '',
            created_at: new Date().toISOString()
          };
          mockDb.chatMessages.push(newMsg);
          return sendJson(res, 200, {
            status: 'SUCCESS',
            code: 200,
            message: newMsg
          });

        case 'REGISTER_STUDENT':
          const newStuId = `STU_DFM_${String(Math.floor(Math.random() * 900) + 100)}`;
          const tempPass = `Dfm@${Math.floor(1000 + Math.random() * 9000)}`;
          const cleanPhone = String(payload.phone || '9827100000').replace(/\D/g, '');
          const waText = encodeURIComponent(
            `🚁 Welcome to DFM Korba Skill Development Course!\n\nYour Student ID: ${newStuId}\nTemporary Password: ${tempPass}\n\nPlease install the DFM Korba App and log in to begin learning. Note: You will be asked to change your password on first login.`
          );
          return sendJson(res, 200, {
            status: 'SUCCESS',
            code: 200,
            student_id: newStuId,
            temporary_password: tempPass,
            whatsapp_url: `https://api.whatsapp.com/send?phone=91${cleanPhone}&text=${waText}`
          });

        default:
          return sendJson(res, 200, {
            status: 'SUCCESS',
            code: 200,
            message: `Mock action [${action}] executed successfully.`,
            action: action,
            timestamp: new Date().toISOString()
          });
      }
    });
  }
});

function handleLogin(payload, res) {
  const { username, password, role } = payload;

  // Generic admin or test user
  const token = `SEC_TOK_${Date.now()}_${Math.random().toString(36).substring(2, 10)}`;

  if (role === 'ADMIN') {
    return sendJson(res, 200, {
      status: 'SUCCESS',
      code: 200,
      token: token,
      user: { id: 'ADM_001', name: 'System Administrator', role: 'ADMIN', must_change_password: false }
    });
  }

  if (role === 'TEACHER') {
    return sendJson(res, 200, {
      status: 'SUCCESS',
      code: 200,
      token: token,
      user: { id: 'TCH_001', name: 'Rajesh Sharma', role: 'TEACHER', must_change_password: false }
    });
  }

  if (role === 'TEAM') {
    return sendJson(res, 200, {
      status: 'SUCCESS',
      code: 200,
      token: token,
      user: { id: 'TM_VEERVAAN', name: 'Team Veervaan', role: 'TEAM', must_change_password: false }
    });
  }

  // Default STUDENT login
  return sendJson(res, 200, {
    status: 'SUCCESS',
    code: 200,
    token: token,
    user: {
      id: 'STU_DFM_001',
      name: 'Aman Verma',
      role: 'STUDENT',
      must_change_password: false,
      course_id: 'CRS_DRONE',
      batch_id: 'BTC_DFM_01',
      team_id: 'TM_VEERVAAN'
    }
  });
}

function getPublicHomeData() {
  return {
    notices: [
      {
        id: 'NOT_001',
        title: 'Next Competition: Cinematic Drone Short Film - 18 Nov 2026',
        category: 'COMPETITION_ALERT',
        content: 'All teams must submit raw 4K footage and color-graded 60s edit by 18 Nov 2026 5:00 PM.'
      },
      {
        id: 'NOT_002',
        title: 'DGCA Micro Drone Regulations Workshop',
        category: 'GENERAL_NOTICE',
        content: 'Special guest session this Saturday covering DGCA Digital Sky compliance in Korba district.'
      }
    ],
    top_team: {
      team_id: 'TM_VEERVAAN',
      team_name: 'Veervaan',
      total_team_marks: 485,
      max_marks: 500,
      performance_pct: 97.0,
      rank: 1,
      members: [
        { name: 'Aman Verma', role: 'Leader' },
        { name: 'Priya Sharma', role: 'Camera' },
        { name: 'Rahul Soni', role: 'Pilot' },
        { name: 'Neha Gupta', role: 'Safety' },
        { name: 'Amit Dewangan', role: 'Editor' },
        { name: 'Rohan Kumar', role: 'Audio' }
      ]
    },
    top_students: [
      { rank: 1, student_name: 'Aman Verma', course_name: 'Drone Film Making', team_name: 'Veervaan', marks: 492, attendance_pct: 100.0 },
      { rank: 2, student_name: 'Priya Sharma', course_name: 'Drone Film Making', team_name: 'Veervaan', marks: 485, attendance_pct: 98.0 },
      { rank: 3, student_name: 'Suresh Patel', course_name: 'Drone Film Making', team_name: 'Garuda Cine Squad', marks: 478, attendance_pct: 96.0 },
      { rank: 4, student_name: 'Kavita Singh', course_name: 'Drone Film Making', team_name: 'Pawanputra Flyers', marks: 465, attendance_pct: 94.0 },
      { rank: 5, student_name: 'Rohan Kumar', course_name: 'Drone Film Making', team_name: 'Veervaan', marks: 458, attendance_pct: 92.0 }
    ],
    gallery: [
      {
        submission_id: 'SUB_001',
        title: 'Hasdeo River Sunrise 4K',
        student_or_team_name: 'Team Veervaan',
        file_name: 'hasdeo_sunrise.mp4',
        mime_type: 'video/mp4',
        marks: 98,
        feedback: 'Outstanding gimbal stability and cinematic golden hour color grading.'
      },
      {
        submission_id: 'SUB_002',
        title: 'Thermal Power Plant Cinematic Reveal',
        student_or_team_name: 'Garuda Cine Squad',
        file_name: 'korba_power_plant.mp4',
        mime_type: 'video/mp4',
        marks: 94,
        feedback: 'Superb parabolic reveal maneuver adhering to DGCA clearance limits.'
      },
      {
        submission_id: 'SUB_003',
        title: 'Chaiturgarh Fort Aerial Panorama',
        student_or_team_name: 'Aman Verma',
        file_name: 'chaiturgarh_fort.mp4',
        mime_type: 'video/mp4',
        marks: 96,
        feedback: 'Dramatic elevation rise with smooth yaw rotation.'
      }
    ],
    courses: [
      { code: 'DFM_01', course_name: 'Drone Film Making', total_modules: 6 },
      { code: 'MR_02', course_name: 'Mobile Hardware & Software Repair', total_modules: 4 },
      { code: 'FOE_03', course_name: 'Front Office Executive', total_modules: 4 },
      { code: 'STE_04', course_name: 'Solar Technician & Installation', total_modules: 5 }
    ]
  };
}

server.listen(PORT, () => {
  console.log(`======================================================================`);
  console.log(`🚀 DFM KORBA MOCK API SERVER ACTIVE ON http://localhost:${PORT}`);
  console.log(`📡 Replicating Google Apps Script & Google Sheets endpoints`);
  console.log(`🔒 Zero external dependencies | Ready for instant mobile device testing`);
  console.log(`======================================================================`);
});

