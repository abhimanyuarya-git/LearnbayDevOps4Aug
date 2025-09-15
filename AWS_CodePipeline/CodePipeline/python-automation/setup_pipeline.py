#!/usr/bin/env python3
"""
SRE-compliant Python automation for AWS CodePipeline
Handles GitHub integration with proper error handling and monitoring
"""

import boto3
import json
import subprocess
import sys
import os
import logging
import time
from pathlib import Path
from botocore.exceptions import ClientError

# SRE: Configure structured logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class PipelineAutomation:
    def __init__(self):
        self.codepipeline = boto3.client('codepipeline')
        self.github_owner = os.getenv('GITHUB_OWNER')
        self.github_repo = os.getenv('GITHUB_REPO', 'LearnbayDevOps4Aug')
        
    def create_github_webhook(self, pipeline_name):
        """Create GitHub webhook with SRE error handling"""
        try:
            logger.info(f"Creating webhook for pipeline: {pipeline_name}")
            
            # Get pipeline details with retry
            response = self._retry_operation(
                lambda: self.codepipeline.get_pipeline(name=pipeline_name)
            )
            
            # Create webhook
            webhook_response = self._retry_operation(
                lambda: self.codepipeline.put_webhook(
                    webhook={
                        'name': f'{pipeline_name}-webhook',
                        'targetPipeline': pipeline_name,
                        'targetAction': 'Source',
                        'filters': [
                            {
                                'jsonPath': '$.ref',
                                'matchEquals': 'refs/heads/develop'
                            }
                        ],
                        'authentication': 'GITHUB_HMAC',
                        'authenticationConfiguration': {
                            'SecretToken': 'webhook-secret-token'
                        }
                    }
                )
            )
            
            webhook_url = webhook_response['webhook']['url']
            logger.info(f"Webhook created successfully: {webhook_url}")
            return webhook_url
            
        except Exception as e:
            logger.error(f"Failed to create webhook: {str(e)}")
            return None
    
    def _retry_operation(self, operation, max_retries=3, delay=2):
        """SRE: Retry operation with exponential backoff"""
        for attempt in range(max_retries):
            try:
                return operation()
            except ClientError as e:
                if attempt == max_retries - 1:
                    raise
                logger.warning(f"Attempt {attempt + 1} failed: {e}. Retrying in {delay}s...")
                time.sleep(delay)
                delay *= 2
        raise Exception("Max retries exceeded")
    
    def register_webhook_with_github(self, webhook_url):
        """Register webhook with GitHub repository"""
        try:
            import requests
            
            github_token = os.getenv('GITHUB_TOKEN')
            if not github_token:
                print("❌ GITHUB_TOKEN environment variable not set")
                return False
            
            headers = {
                'Authorization': f'token {github_token}',
                'Accept': 'application/vnd.github.v3+json'
            }
            
            webhook_data = {
                'name': 'web',
                'active': True,
                'events': ['push'],
                'config': {
                    'url': webhook_url,
                    'content_type': 'json',
                    'secret': 'webhook-secret-token'
                }
            }
            
            response = requests.post(
                f'https://api.github.com/repos/{self.github_owner}/{self.github_repo}/hooks',
                headers=headers,
                json=webhook_data
            )
            
            if response.status_code == 201:
                print("✅ GitHub webhook registered successfully")
                return True
            else:
                print(f"❌ Failed to register GitHub webhook: {response.text}")
                return False
                
        except ImportError:
            print("❌ requests library not installed. Run: pip install requests")
            return False
        except Exception as e:
            print(f"❌ Error registering GitHub webhook: {str(e)}")
            return False
    
    def start_pipeline(self, pipeline_name):
        """Start pipeline execution for testing"""
        try:
            response = self.codepipeline.start_pipeline_execution(
                name=pipeline_name
            )
            execution_id = response['pipelineExecutionId']
            print(f"✅ Pipeline started: {execution_id}")
            return execution_id
        except Exception as e:
            print(f"❌ Error starting pipeline: {str(e)}")
            return None

def main():
    """Main automation workflow"""
    print("🚀 Starting AWS CodePipeline Python Automation")
    
    # Check required environment variables
    required_vars = ['GITHUB_OWNER', 'GITHUB_TOKEN']
    missing_vars = [var for var in required_vars if not os.getenv(var)]
    
    if missing_vars:
        print(f"❌ Missing environment variables: {', '.join(missing_vars)}")
        sys.exit(1)
    
    automation = PipelineAutomation()
    
    # Get pipeline name from Terraform output
    try:
        result = subprocess.run(
            ['terraform', 'output', '-raw', 'pipeline_name'],
            cwd='../terraform',
            capture_output=True,
            text=True,
            check=True
        )
        pipeline_name = result.stdout.strip()
        print(f"📋 Pipeline Name: {pipeline_name}")
    except subprocess.CalledProcessError:
        print("❌ Could not get pipeline name from Terraform. Run terraform apply first.")
        sys.exit(1)
    
    # Create and register webhook
    webhook_url = automation.create_github_webhook(pipeline_name)
    if webhook_url:
        automation.register_webhook_with_github(webhook_url)
    
    # Test pipeline
    print("\n🧪 Testing pipeline execution...")
    execution_id = automation.start_pipeline(pipeline_name)
    
    if execution_id:
        print(f"Monitor pipeline at: https://console.aws.amazon.com/codesuite/codepipeline/pipelines/{pipeline_name}/view")
    
    print("✅ Python automation completed!")

if __name__ == "__main__":
    main()