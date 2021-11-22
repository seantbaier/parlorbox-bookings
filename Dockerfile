FROM public.ecr.aws/lambda/python:3.8

ENV handler="app.main"

# Install Poetry
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | POETRY_HOME=/opt/poetry python && \
  cd /usr/local/bin && \
  ln -sf /opt/poetry/bin/poetry && \
  poetry config virtualenvs.create false

# Copy poetry.lock* in case it doesn't exist in the repo
COPY ./pyproject.toml ./poetry.lock* /

RUN poetry install --no-root

COPY . ${LAMBDA_TASK_ROOT}

COPY requirements.txt  .

RUN pip3 install -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

RUN chmod +x ./start.sh

# WORKDIR /app

# ENV PYTHONPATH=/app

CMD ./start.sh