FROM python:3.7.6-alpine
RUN pip install django \
    && pip install django-bootstrap4
WORKDIR /app
VOLUME ["/app"]
EXPOSE 8000
ENTRYPOINT ["python","manage.py","runserver","0.0.0.0:8000"]
