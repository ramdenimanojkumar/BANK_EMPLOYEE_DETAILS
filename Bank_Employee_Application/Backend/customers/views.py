import logging

from django.db import DatabaseError, connection
from rest_framework import viewsets
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.status import HTTP_503_SERVICE_UNAVAILABLE

from .models import Customer
from .serializers import CustomerSerializer

logger = logging.getLogger(__name__)


class CustomerViewSet(viewsets.ModelViewSet):
    queryset = Customer.objects.all()
    serializer_class = CustomerSerializer
    lookup_field = "customer_id"
    permission_classes = [AllowAny]
    http_method_names = ["get", "post", "head", "options"]


@api_view(["GET"])
@permission_classes([AllowAny])
def health_check(request):
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            cursor.fetchone()
    except DatabaseError:
        logger.exception("Health check could not reach the configured database.")
        return Response(
            {"status": "error", "database": "unavailable"},
            status=HTTP_503_SERVICE_UNAVAILABLE,
        )

    return Response({"status": "ok", "database": "connected"})
