from sklearn.datasets import load_iris
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import accuracy_score
import numpy as np

data = load_iris(as_frame=True)
df = data.frame
X = df.drop(columns=['target'])
y = df['target']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.25, random_state=42)

model = DecisionTreeClassifier(max_depth=3, random_state=42)
model.fit(X_train, y_train)

# Introduce a synthetic 'segment' column for testing fairness
np.random.seed(42)
df['segment'] = np.random.choice(['Group A', 'Group B'], size=len(df), p=[0.7, 0.3])

print("Representation by Segment:")
print(df.groupby('target')['segment'].value_counts(normalize=True))

features = X.columns
print("\nAccuracy by Segment:")
for group in df['segment'].unique():
    subset = df[df['segment'] == group]
    preds = model.predict(subset[features])
    print(group, accuracy_score(subset['target'], preds))

# Discuss and document findings as per lab instructions
print("\n--- Model Card / Ethical Analysis ---")
print("Finding 1: Subgroup under-representation. Group B has lower representation in the dataset.")
print("Finding 2: Potential performance disparity depending on subgroup accuracy.")
