import csv
import re
import string

def update_csv(words, answer):
    file_path = '/Volumes/Island_Societe/Island-Technologies/DevOps/Biased_YesNo/YesNo/YesNo/YesNo_input.csv'  # Replace with the actual file path

    with open(file_path, 'r') as file:
        reader = csv.reader(file)
        rows = list(reader)

        # Extract the headers and data from the CSV file
        headers = rows[0]
        data = rows[1:]

        # Get the index of the columns
        id_index = headers.index('id')
        name_index = headers.index('name')
        i_index = headers.index('weighting_i')
        j_index = headers.index('weighting_j')

        # Check if each word exists in the data
        for word in words:
            word_exists = False
            for row in data:
                if row[name_index] == word:
                    word_exists = True
                    if answer.lower() == 'yes':
                        row[i_index] = str(int(row[i_index]) + 1)
                    elif answer.lower() == 'no':
                        row[j_index] = str(int(row[j_index]) + 1)

            # If the word doesn't exist, create a new row
            if not word_exists:
                new_row = [str(len(data) + 1), word, '1', '1', '0']
                if answer.lower() == 'yes':
                    new_row[i_index] = '2'
                elif answer.lower() == 'no':
                    new_row[j_index] = '2'
                data.append(new_row)
        
        yesNoKey = data[0] # adds if the question was yes or no
        if answer.lower() == 'yes':
            yesNoKey[2] = str(int(yesNoKey[2]) + 1)
        elif answer.lower() == 'no':
            yesNoKey[3] = str(int(yesNoKey[3]) + 1)

    # Write the updated data back to the CSV file
    with open(file_path, 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(headers)
        writer.writerows(data)

# Request user input
question = input("Enter a yes or no question: ")
answer = input("Is the answer yes or no? ")

# Remove punctuation marks from the question
question = question.translate(str.maketrans('', '', string.punctuation))

# Split the question into individual words, convert to lowercase
words = re.findall(r'\w+', question.lower())

# Call the function to update the CSV file
update_csv(words, answer)
