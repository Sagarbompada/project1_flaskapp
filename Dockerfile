#Single Docer build
# 1. Base image (runtime)
FROM python:3.11-slim

# 2. Set working directory inside container
WORKDIR /app

# 3. Copy dependency file first (for caching)
COPY requirements.txt .

# 4. Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copy application code
COPY . .

# 6. Expose application port
EXPOSE 5000

# 7. Start application
CMD ["python", "app.py"]


