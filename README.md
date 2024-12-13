# Pantry Pal 🍳  
Your personal cooking assistant to transform culinary chaos into delicious meals!

---

## **Introduction**  
Ever found yourself staring at a pantry full of ingredients but still clueless about what to cook? Or perhaps you're juggling a busy life in Bangalore and struggling to stick to a meal plan? **Pantry Pal** is here to save the day!  

Pantry Pal is a feature-rich app designed to help you:  
- Suggest recipes based on your pantry ingredients.  
- Create personalized meal plans based on your calorie requirements and dietary preferences.  
- Generate recipes from images of dishes.  
- Manage your pantry effortlessly with voice commands or by scanning receipts.  

This project was built as part of the **Build and Blog Hackathon** conducted by **Google** and **Code Vipassana** at the **Google Kyoto Office, Bengaluru** on **12th and 13th December 2024**.

---

## **Features**  
- **Recipe Suggestions**: Based on ingredients available in your pantry.  
- **Chatbot Assistance**: Powered by Dialogflow CX with a Recipe CookBook for RAG answers.  
- **Meal Planner**: Personalized meal plans tailored to dietary and calorie needs.  
- **Image-Based Recipe Generation**: Upload a photo of a dish to get its recipe.  
- **Pantry Management**: Add items manually, scan bills (Swiggy, Blinkit, Zepto), or use voice commands to update inventory.  
- **Notifications**: Get timely push notifications for reminders, meal suggestions, and updates.  

---

## **Tech Stack**  
- **Frontend**: Flutter  
- **Backend**: Firebase Realtime Database, Firestore  
- **Machine Learning**: Gemini 2.0 for image recognition and meal planning  
- **Chatbot**: Dialogflow CX integrated with a Recipe CookBook  
- **Cloud Functions**: Google Cloud Run for notifications and serverless functionalities  
- **Voice Processing**: `flutter_speech_to_text`  

---

## **Architecture Diagram**  
 

---

## **How It Works**  
1. **Manage Your Pantry**: Update your pantry by manually adding ingredients, scanning receipts, or using voice commands.  
2. **Get Recipe Suggestions**: The app matches your pantry inventory with a dataset to suggest recipes.  
3. **Chatbot Assistance**: Ask questions like "How to use leftover paneer?" and get quick, relevant answers.  
4. **Plan Your Meals**: Generate a meal plan based on your preferences and calorie goals.  
5. **Image-Based Recipes**: Upload a dish photo and receive the full recipe instantly.  
6. **Stay Notified**: Get push notifications for updates and meal suggestions.  

---

## **Dataset and References**  
- **Recipe Dataset**: [Kaggle Link](https://www.kaggle.com/datasets/sooryaprakash12/cleaned-indian-recipes-dataset)  
- **CookBook for RAG**: [PDF Link](https://floritaindia.com/wp-content/uploads/2020/09/Indian-Recipes.pdf)  

---

## **Future Improvements**  
- AI-based nutritional recommendations.  
- Multi-language support for wider accessibility.  
- Integration with grocery platforms for automated shopping lists.  
- Augmented reality (AR) for pantry management.  

---
