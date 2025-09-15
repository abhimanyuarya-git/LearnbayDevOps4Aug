const express = require('express');
const { CodeGuruProfilerAgent } = require('@aws/codeguru-profiler-nodejs-agent');

// Initialize CodeGuru Profiler
CodeGuruProfilerAgent.start({
    profilingGroupName: 'MyApp-Profiler',
    region: 'us-east-1'
});

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        version: process.env.npm_package_version || '1.0.0'
    });
});

// Root endpoint
app.get('/', (req, res) => {
    res.json({
        message: 'AWS CodePipeline Sample Application',
        environment: process.env.NODE_ENV || 'development'
    });
});

// API endpoint
app.get('/api/status', (req, res) => {
    res.json({
        api: 'running',
        uptime: process.uptime(),
        memory: process.memoryUsage()
    });
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});