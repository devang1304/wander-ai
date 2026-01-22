import json
import os
from aws_lambda_powertools import Logger
from openai import OpenAI

logger = Logger()
client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

@logger.inject_lambda_context
def lambda_handler(event, context):
    try:
        body = json.loads(event.get('body', '{}'))
        research_content = body.get('research_content')
        user_preferences = body.get('user_preferences')
        
        if not research_content or not user_preferences:
            return {'statusCode': 400, 'body': json.dumps({'error': 'Missing data'})}
            
        logger.info("Generating Plan")
        
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": "You are an expert travel planner. Create a JSON itinerary based on the research and preferences. Return ONLY valid JSON with keys: days (array), estimated_cost."},
                {"role": "user", "content": f"Research: {research_content}\nPreferences: {user_preferences}"}
            ],
            response_format={"type": "json_object"}
        )
        
        plan_json = response.choices[0].message.content
        
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'plan': plan_json})
        }
    except Exception as e:
        logger.exception("Planning Agent failed")
        return {'statusCode': 500, 'body': json.dumps({'error': str(e)})}
