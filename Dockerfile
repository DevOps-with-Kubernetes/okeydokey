FROM alpine:3.8
EXPOSE 5000
RUN apk add --no-cache python3 coreutils
ADD app.py .
CMD ["python3", "-u", "app.py"]
