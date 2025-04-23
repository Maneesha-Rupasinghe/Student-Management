from django.urls import path
from .views import (
    AddQuizQuestionsView,
    AddResourceView,
    CustomTokenObtainPairView,
    CustomTokenRefreshView,
    DeleteProfileView,
    GetQuizQuestions,
    RegisterView,
    SaveQuizResultView,
    UpdateProfileView,
)

urlpatterns = [
    path("register/", RegisterView.as_view(), name="register"),
    path("profile/update/", UpdateProfileView.as_view(), name="update-profile"),
    path("profile/delete/", DeleteProfileView.as_view(), name="delete-profile"),
    path("token/", CustomTokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("token/refresh/", CustomTokenRefreshView.as_view(), name="token_refresh"),
    path("questions/add/", AddQuizQuestionsView.as_view(), name="add-quiz-questions"),
    path("resources/add/", AddResourceView.as_view(), name="add-resource"),
    path("questions/", GetQuizQuestions.as_view(), name="get-quiz-questions"),
    path('quiz/results/save/', SaveQuizResultView.as_view(), name='save-quiz-result'),
]


# {
#     "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc1Mzg1NzQyNSwiaWF0IjoxNzQ1MjE3NDI1LCJqdGkiOiJlYTExMjc0NDVlYzA0Yzk3YmYxZTY3MDA5NzVhYjNjMCIsInVzZXJfaWQiOjF9.jPgUPnNAni7b3Yw1Sa6iEkwnXRX5zxpUWrRMAtk-0qY",
#     "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzQ4ODE3NDI1LCJpYXQiOjE3NDUyMTc0MjUsImp0aSI6ImFmZDNkNjRmODhiOTQ4YTNhZjQ4ZWQ2MTc5NzZjNTk1IiwidXNlcl9pZCI6MX0.NQYDXcyEKzBO3c7YL9bpMIiOEbYMQ5rF00aQdDK8kAk"
# }
