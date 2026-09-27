from sklearn.datasets import load_iris
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import accuracy_score, classification_report
from sklearn.neighbors import KNeighborsClassifier

# Load a sample dataset and inspect its structure
data = load_iris(as_frame=True)
df = data.frame
print("Dataset Head:")
print(df.head())
print("\nTarget Value Counts:")
print(df['target'].value_counts())

# Split the dataset into training and testing sets
X = df.drop(columns=['target'])
y = df['target']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.25, random_state=42)

# Train a simple classification algorithm
model_dt = DecisionTreeClassifier(max_depth=3, random_state=42)
model_dt.fit(X_train, y_train)

# Generate predictions and evaluate accuracy
predictions_dt = model_dt.predict(X_test)
print("\nDecision Tree Accuracy:", accuracy_score(y_test, predictions_dt))
print(classification_report(y_test, predictions_dt))

# Experiment with a second algorithm
model_knn = KNeighborsClassifier()
model_knn.fit(X_train, y_train)
predictions_knn = model_knn.predict(X_test)
print("\nK-Nearest Neighbors Accuracy:", accuracy_score(y_test, predictions_knn))
print(classification_report(y_test, predictions_knn))
