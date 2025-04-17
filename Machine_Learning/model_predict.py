import pandas as pd
import numpy as np
from sklearn.preprocessing import MinMaxScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout
import matplotlib.pyplot as plt

# Load dataset
data = pd.read_csv('/content/AC_with_power_energy_with_frequency.csv')

# Feature Engineering
data['Power Consumption'] = data['voltage'] * data['current'] * data['power factor']
data['Temperature Change'] = 0.5 * data['Power Consumption']

# Scale features
scaler = MinMaxScaler()
features = ['voltage', 'current', 'Power Consumption', 'frequency', 'power factor', 'Temperature Change']
scaled_features = scaler.fit_transform(data[features])

# Create sequences
def create_sequences(X, y, time_steps=1):
    Xs, ys = [], []
    for i in range(len(X) - time_steps):
        v = X[i:(i + time_steps)]
        Xs.append(v)
        ys.append(y[i + time_steps])
    return np.array(Xs), np.array(ys)

time_steps = 10
X, y = create_sequences(scaled_features, data['Power Consumption'], time_steps)

# Split data into train and test sets
split = int(0.8 * len(X))
X_train, X_test = X[:split], X[split:]
y_train, y_test = y[:split], y[split:]

def create_model(input_shape):
    model = Sequential()
    model.add(LSTM(50, return_sequences=True, input_shape=input_shape))
    model.add(Dropout(0.2))
    model.add(LSTM(50))
    model.add(Dropout(0.2))
    model.add(Dense(1))
    model.compile(optimizer='adam', loss='mean_squared_error')
    return model

model = create_model(((X_train.shape[1], X_train.shape[2])))
history = model.fit(X_train, y_train, epochs=50, batch_size=32, validation_data=(X_test, y_test), verbose=1)


# Predict on new data
predictions = model.predict(X_test)

# Convert predictions to DataFrame for easier manipulation
predictions_df = pd.DataFrame(predictions.flatten(), columns=['Predicted Power Consumption'])

# Calculate energy consumption condition
def classify_energy_consumption(energy):
    if energy <= 18:
        return 'Best Condition'
    elif 18 < energy <= 22:
        return 'Average Condition'
    else:
        return 'Worst Condition'

data['Energy Consumption Condition'] = predictions_df['Predicted Power Consumption'].apply(classify_energy_consumption)

# Calculate power factor efficiency
def classify_power_factor(pf):
    if pf > 0.8:
        return 'Best Case'
    elif 0.7 <= pf <= 0.8:
        return 'Average Case'
    else:
        return 'Worst Case'

data['Power Factor Efficiency'] = data['power factor'].apply(classify_power_factor)
data['Power Consumption']
# Calculate temperature change
data['Temperature'] = 0.5 * predictions_df['Predicted Power Consumption']

# Voltage alert
data['Voltage Alert'] = np.where((data['voltage'] >= 250) | (data['voltage'] <= 190), 'High Alert', 'Normal')

#current alert
data['Current Alert'] = np.where((data['current'] >= 20) | (data['current'] <= 5), 'High Alert', 'Normal')

# Define the condition function with corrected power factor thresholds
def diagnose_problems(row):
    problems = []

    # Condition 1: High current, low voltage, poor PF
    if row['current'] > 20 and row['power factor'] < 0.6 and row['voltage'] <= 190:
        problems.append('Low Cooling Efficiency')
        problems.append('High Energy Consumption')
        problems.append('Compressor Damage Possible')
        problems.append('Overheating')
        problems.append('Motor Issue Possible')
        problems.append('Change Wires Required')

    # Condition 2: Very low power and current + low PF
    if row['Power Consumption'] < 1.2 and row['current'] < 5 and row['power factor'] < 0.6:
        problems.append('Refrigerant Leak')
        problems.append('Capacitor Fault Possible')

    # Condition 3: High power + high current
    if row['Power Consumption'] > 1700 and row['current'] > 20:
        problems.append('Dust in Unit')
        problems.append('Coil Dirt Issue')

    return ', '.join(problems) if problems else 'No Issues Detected'

# Apply the updated function to your DataFrame
data['Possible Problems'] = data.apply(diagnose_problems, axis=1)


# Calculate EER
CFM = 600
data['EER'] = (1.08 * CFM * (data['Temperature'])) / (data['voltage'] * data['current'] * data['power factor'])

# EER condition
def classify_EER(EER):
    if EER > 11:
        return 'Good Condition'
    elif 7.5 <= EER <= 10.9:
        return 'Average Condition'
    else:
        return 'Worst Condition'

data['EER Condition'] = data['EER'].apply(classify_EER)

# Operational status
data['Operational Status'] = np.where((data['voltage'] > 0) & (data['current'] > 0), 1, 0)

data.to_csv('processed_data.csv', index=False)

# Load the CSV file into a DataFrame
processed_data = pd.read_csv('processed_data.csv')

# Print the DataFrame
print(processed_data)
model.save('my_model.h5')
