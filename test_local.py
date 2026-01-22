"""
Local test script for WanderAI Lambda agents.
Run with: python test_local.py
"""
import sys
import os

# Add backend to path so we can import modules
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'backend', 'src'))

from agents.research_agent import lambda_handler as research_handler
from agents.planning_agent import lambda_handler as planning_handler


class MockContext:
    """Mock AWS Lambda context for local testing."""
    def __init__(self):
        self.aws_request_id = "test-id"
        self.function_name = "test-function"
        self.memory_limit_in_mb = 128
        self.invoked_function_arn = "arn:aws:lambda:us-east-1:123456789012:function:test-function"


def test_agents():
    print("Testing WanderAI Agents Locally...")
    
    # 1. Test Research Agent
    print("\n--- Testing Research Agent ---")
    research_event = {
        "body": '{"input": "Top 3 tourist attractions in Kyoto"}'
    }
    
    try:
        research_response = research_handler(research_event, MockContext())
        print("Research Status:", research_response['statusCode'])
        body = research_response['body']
        print("Research Body:", body[:200] + "..." if len(body) > 200 else body)
    except Exception as e:
        print(f"Research Failed: {e}")
        return

    # 2. Test Planning Agent
    print("\n--- Testing Planning Agent ---")
    plan_event = {
        "body": '{"research_content": "Kyoto has Kinkaku-ji, Fushimi Inari, and Arashiyama.", "user_preferences": "I like historic sites."}' 
    }
    
    try:
        plan_response = planning_handler(plan_event, MockContext())
        print("Planning Status:", plan_response['statusCode'])
        print("Planning Body:", plan_response['body'])
    except Exception as e:
        print(f"Planning Failed: {e}")


if __name__ == "__main__":
    if not os.environ.get("OPENAI_API_KEY"):
        print("ERROR: OPENAI_API_KEY env var not set.")
        print("Run: export OPENAI_API_KEY=sk-your-key")
    else:
        test_agents()
