from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import Pipeline
import joblib

# Sample support ticket dataset
ticket_texts = [
    "My payment was charged twice",
    "I need a refund",
    "How do I update my billing info",
    "The website is down",
    "I cannot log in",
    "Page is loading slowly",
]
ticket_categories = [
    "billing",
    "billing",
    "billing",
    "technical",
    "technical",
    "technical"
]

pipeline = Pipeline([
    ('tfidf', TfidfVectorizer()),
    ('clf', LogisticRegression(max_iter=1000)),
])

pipeline.fit(ticket_texts, ticket_categories)
joblib.dump(pipeline, 'ticket_classifier.joblib')
print("Model saved to ticket_classifier.joblib")
