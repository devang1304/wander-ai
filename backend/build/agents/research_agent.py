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
        user_input = body.get('input')
        
        if not user_input:
            return {'statusCode': 400, 'body': json.dumps({'error': 'Missing input'})}
            
        logger.info(f"Researching: {user_input}")
        
        # Simulating Search to avoid heavy dependencies (tiktoken/langchain)
        # In a real scenario, use 'requests' to hit a SERP API (Serper, Bing, etc)
        # using a mock here allows strictly minimal build success.
        search_context = f"Simulated travel info for: {user_input}. " \
                         f"Assume typical popular destinations and activities for this query."
        
        # Direct OpenAI call - No LangChain
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": "You are a travel researcher. Provide a summary of top travel options based on the query."},
                {"role": "user", "content": f"Query: {user_input}\nContext: {search_context}"}
            ]
        )
        
        summary = response.choices[0].message.content
        
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'output': summary})
        }
    except Exception as e:
        logger.exception("Research Agent failed")
        return {'statusCode': 500, 'body': json.dumps({'error': str(e)})}
