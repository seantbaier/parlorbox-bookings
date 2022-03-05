FROM public.ecr.aws/lambda/python:3.8


# Install Poetry
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | POETRY_HOME=/opt/poetry python && \
  cd /usr/local/bin && \
  ln -sf /opt/poetry/bin/poetry && \
  poetry config virtualenvs.create false

ADD function/ .

COPY pyproject.toml .

WORKDIR ${LAMBDA_TASK_ROOT}

RUN poetry install --no-root

CMD [ "app.handler" ]