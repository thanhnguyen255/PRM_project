const puppeteer = require('puppeteer');
const fs = require('fs');

async function run() {
    const browser = await puppeteer.launch({ headless: 'new' });
    const page = await browser.newPage();
    await page.setViewport({ width: 1280, height: 800 });

    const baseUrl = 'http://localhost:8080/#';
    const screens = [
        { id: 'SCR-L01', route: '/login', name: 'Login_Screen' },
        { id: 'SCR-L03', route: '/register', name: 'Register_Screen' },
        { id: 'SCR-L04', route: '/forgot-password', name: 'Forgot_Password_Screen' },
        { id: 'SCR-L05', route: '/dashboard', name: 'Dashboard_Screen' },
        { id: 'SCR-L06', route: '/courses', name: 'Course_List_Screen' },
        { id: 'SCR-L07', route: '/courses/1', name: 'Course_Detail_Screen' },
        { id: 'SCR-L08', route: '/classes/1', name: 'Class_Dashboard_Screen' },
        { id: 'SCR-L09', route: '/classes/1/members', name: 'Class_Members_Screen' },
        { id: 'SCR-L10', route: '/learning-paths/1', name: 'Learning_Path_List_Screen' },
        { id: 'SCR-L11', route: '/learning-paths/1/detail', name: 'Learning_Path_Detail_Screen' },
        { id: 'SCR-L13', route: '/materials/1', name: 'Materials_List_Screen' },
        { id: 'SCR-L14', route: '/materials/1/detail', name: 'Material_Detail_Screen' },
        { id: 'SCR-L15', route: '/materials/1/video', name: 'Video_Player_Screen' },
        { id: 'SCR-L16', route: '/materials/1/document', name: 'Document_Viewer_Screen' },
        { id: 'SCR-L17', route: '/activities/1/pre-class', name: 'Pre_Class_Activities_Screen' },
        { id: 'SCR-L18', route: '/activities/1/pre-class/1', name: 'Pre_Class_Detail_Screen' },
        { id: 'SCR-L19', route: '/activities/1/pre-class/1/submit', name: 'Submit_Pre_Evidence_Screen' },
        { id: 'SCR-L20', route: '/activities/1/in-class', name: 'In_Class_Activities_Screen' },
        { id: 'SCR-L21', route: '/activities/1/in-class/2', name: 'In_Class_Detail_Screen' },
        { id: 'SCR-L22', route: '/activities/1/in-class/2/submit', name: 'Submit_In_Class_Evidence_Screen' },
        { id: 'SCR-L23', route: '/activities/1/post-class', name: 'Post_Class_Activities_Screen' },
        { id: 'SCR-L24', route: '/activities/1/post-class/3', name: 'Post_Class_Detail_Screen' },
        { id: 'SCR-L25', route: '/activities/1/post-class/3/submit', name: 'Submit_Reflection_Screen' },
        { id: 'SCR-L26', route: '/projects', name: 'Project_List_Screen' },
        { id: 'SCR-L27', route: '/projects/1', name: 'Project_Detail_Screen' },
        { id: 'SCR-L28', route: '/projects/1/milestones', name: 'Milestone_List_Screen' },
        { id: 'SCR-L29', route: '/projects/1/milestones/1', name: 'Milestone_Detail_Screen' },
        { id: 'SCR-L30', route: '/projects/1/milestones/1/submit', name: 'Submit_Milestone_Screen' },
        { id: 'SCR-L31', route: '/review-sessions', name: 'Review_Sessions_Screen' },
        { id: 'SCR-L32', route: '/review-sessions/1', name: 'Review_Detail_Screen' },
    ];

    console.log('Capturing screens...');
    
    console.log('Registering to get JWT token...');
    try {
        const res = await fetch('http://localhost:5111/api/auth/register', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email: 'tester_' + Date.now() + '@test.com', password: '123456', fullName: 'Tester' })
        });
        const data = await res.json();
        if (data.success && data.data && data.data.token) {
            const token = data.data.token;
            console.log('Got token from register:', token.substring(0, 20) + '...');
            
            // Set token in localStorage for flutter web
            await page.goto(baseUrl, { waitUntil: 'networkidle2' });
            await page.evaluate((t) => {
                localStorage.setItem('flutter.token', '"' + t + '"');
                localStorage.setItem('flutter.userId', '2'); // hardcoded for seeded data
                localStorage.setItem('flutter.role', '"Learner"');
            }, token);
            console.log('Token injected to localStorage.');
        } else {
            console.log('Register failed, capturing screens anyway. Response:', data);
        }
    } catch (e) {
        console.error('Failed to register:', e.message);
    }

    for (const screen of screens) {
        console.log(`Navigating to ${screen.id}: ${screen.name}...`);
        await page.goto(baseUrl + screen.route, { waitUntil: 'networkidle2' });
        
        // Wait a bit for flutter to render canvas
        await new Promise(r => setTimeout(r, 2000));
        
        await page.screenshot({ path: `../${screen.id}_${screen.name}.png` });
        console.log(`Saved ../${screen.id}_${screen.name}.png`);
    }

    await browser.close();
    console.log('Done.');
}

run().catch(console.error);
