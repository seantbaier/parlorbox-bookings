FROM public.ecr.aws/lambda/python:3.8

# Install Poetry
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | POETRY_HOME=/opt/poetry python && \
  cd /usr/local/bin && \
  ln -sf /opt/poetry/bin/poetry && \
  poetry config virtualenvs.create false


COPY ./pyproject.toml ./poetry.lock* ${LAMBDA_TASK_ROOT}/

# RUN cd ${LAMBDA_TASK_ROOT} poetry install --no-root
RUN cd ${LAMBDA_TASK_ROOT} poetry install --no-root

# COPY ./dataservices/post_confirmation_trigger ${LAMBDA_TASK_ROOT}

COPY function/ ${LAMBDA_TASK_ROOT}

COPY requirements.txt .

RUN  pip3 install -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

CMD [ "app.handler" ]