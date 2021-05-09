from django.urls import path

from apps.core import views

urlpatterns = [
    path("health-check/", views.health_check, name="health_check"),
]
