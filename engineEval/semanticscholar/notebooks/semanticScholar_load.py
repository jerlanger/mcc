import requests
import json
import pandas as pd
import numpy as np
from ratelimit import limits, RateLimitException, sleep_and_retry
from backoff import on_exception, expo

@sleep_and_retry
@limits(calls=99, period=330)
def query_api(query, scroll=0):
    
    base = "https://api.semanticscholar.org/graph/v1"
    obj = "paper"
    limit = 100
    fields = "abstract,title,year,externalIds"
    
    response = requests.get(f"{base}/{obj}/search?query={query}&limit={limit}&offset={scroll}&fields={fields}").json()

    return response

def scroll(query, scroll=0, suffix=None):
    
    allResults = []
    
    result = query_api(query, scroll=scroll)
    
    jsonString = json.dumps(result)
    jsonFile = open(f"../engineEval/semanticScholar/q2_results/{scroll}{suffix}_results.json", "w")
    jsonFile.write(jsonString)
    jsonFile.close()
        
    totalResults = result["total"]
    allResults.append(result["data"])
    
    while (scroll <= 9800) & ("next" in result.keys()):
        print(scroll)
        scroll = result["next"]
        result = query_api(query, scroll=scroll)
        allResults.append(result["data"])
        
        jsonString = json.dumps(result)
        jsonFile = open(f"../engineEval/semanticScholar/q2_results/{scroll}{suffix}_results.json", "w")
        jsonFile.write(jsonString)
        jsonFile.close()
        
    return allResults

scroll("c02 capture and storage", suffix="_c02")
scroll("carbon capture and storage", suffix="_carbon")

