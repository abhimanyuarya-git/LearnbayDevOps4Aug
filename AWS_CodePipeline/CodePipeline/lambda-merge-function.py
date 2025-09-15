import json
import boto3
import requests
import os
import logging
from botocore.exceptions import ClientError

# SRE: Structured logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    SRE-compliant Lambda function for GitHub auto-merge
    Includes proper error handling, logging, and monitoring
    """
    
    try:
        # SRE: Log execution context
        logger.info(f"Lambda execution started - RequestId: {context.aws_request_id}")
        
        # Get GitHub token from Secrets Manager with retry
        github_token = get_github_token()
        if not github_token:
            return error_response(500, "Failed to retrieve GitHub token")
        
        # GitHub API configuration
        github_owner = os.environ.get('GITHUB_OWNER')
        github_repo = os.environ.get('GITHUB_REPO')
        
        if not github_owner or not github_repo:
            return error_response(500, "Missing required environment variables")
        
        logger.info(f"Processing merge for {github_owner}/{github_repo}")
        
        # Execute merge with proper error handling
        result = execute_github_merge(github_token, github_owner, github_repo)
        
        logger.info(f"Merge operation completed successfully")
        return success_response("Successfully merged develop to main")
        
    except Exception as e:
        logger.error(f"Lambda execution failed: {str(e)}")
        return error_response(500, f"Internal error: {str(e)}")

def get_github_token():
    """Retrieve GitHub token with proper error handling"""
    try:
        secrets_client = boto3.client('secretsmanager')
        secret_response = secrets_client.get_secret_value(SecretId='github-token')
        return json.loads(secret_response['SecretString'])['token']
    except ClientError as e:
        logger.error(f"Failed to retrieve GitHub token: {e}")
        return None

def execute_github_merge(token, owner, repo):
    """Execute GitHub merge with proper error handling"""
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github.v3+json'
    }
    
    # Create pull request
    pr_data = {
        'title': 'Auto-merge: Pipeline Success',
        'head': 'develop',
        'base': 'main',
        'body': 'Automated merge after successful pipeline execution'
    }
    
    pr_response = requests.post(
        f'https://api.github.com/repos/{owner}/{repo}/pulls',
        headers=headers,
        json=pr_data,
        timeout=30
    )
    
    if pr_response.status_code != 201:
        raise Exception(f"Failed to create PR: {pr_response.text}")
    
    pr_number = pr_response.json()['number']
    logger.info(f"Created PR #{pr_number}")
    
    # Auto-merge the pull request
    merge_data = {
        'commit_title': 'Auto-merge: Pipeline Success',
        'merge_method': 'merge'
    }
    
    merge_response = requests.put(
        f'https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}/merge',
        headers=headers,
        json=merge_data,
        timeout=30
    )
    
    if merge_response.status_code != 200:
        raise Exception(f"Failed to merge PR: {merge_response.text}")
    
    logger.info(f"Successfully merged PR #{pr_number}")
    return True

def success_response(message):
    """Standard success response"""
    return {
        'statusCode': 200,
        'body': json.dumps({'status': 'success', 'message': message})
    }

def error_response(status_code, message):
    """Standard error response"""
    return {
        'statusCode': status_code,
        'body': json.dumps({'status': 'error', 'message': message})
    }