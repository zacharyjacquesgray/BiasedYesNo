# BiasedYesNo
Biased Yes No iOS Application

DESCRIPTION:
> Allows user to enter questions into the main View: YesNoMain, and this will call on a MySQL database hosted on a web server to provide a biased Yes-No response based on probabilities and statistics for the question.

> The general idea is that for every 10 friends you ask a yes/no question, maybe 7 will say 'yes' but 3 will say 'no'. In this case the Biased Yes/No app will then be set with a probability of 70% (depending on the question) as opposed to just 50%.

> In time, the app is to take user input and use this to converge the biasedness to a general concensus for each search term. Additionally will use these statistics to predict biased responses for new input terms.

USER INTERFACE (YesNoMain.swift)
<img width="355" alt="Screenshot 2023-03-15 at 7 51 13 pm" src="https://user-images.githubusercontent.com/127930775/225257085-a240da66-c679-481a-bbfa-98bb54ada62c.png">
<img width="383" alt="Screenshot 2023-03-15 at 7 51 44 pm" src="https://user-images.githubusercontent.com/127930775/225257155-f056ae27-4f8e-4a9a-9911-dd50f1441c51.png">
> Currently displaying the JSON generated from the http request from the MySQL database, and showing basic calculations. This is just during development to see exactly what information is being generated and to ensure the correct data is being used correctly.
<img width="373" alt="Screenshot 2023-03-15 at 7 53 31 pm" src="https://user-images.githubusercontent.com/127930775/225257182-24ce5214-4f50-413d-8b1f-c50937cdf26f.png">
