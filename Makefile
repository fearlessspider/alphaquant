PROJECT_NAME = alphaquant
SHELL := /bin/sh
help:
	@echo "Please use 'make <target>' where <target> is one of"
	@echo "  all                      to setup the whole development environment for the project"
	@echo "  virtualenv               to create the virtualenv for the project"
	@echo "  migrate                  run the migrations"
	@echo "  initial_data             populate the site with initial page structure"
	@echo "  runserver                Start the django dev server"
	@echo "  superuser                Create superuser with name superuser and password pass"
	@echo "  test                     run tdd tests"
	@echo "  robot step=...           run bdd tests"
	@echo "  compilemessages          compile locale messages"
	@echo "  messages                 create locale messages"

.PHONY: requirements

all: virtualenv

dev: all update_dev migrate superuser update_fixtures runserver

prod: all update_prod migrate update_static compilemessages superuser update_fixtures

# Command variables
MANAGE_CMD = python3 manage.py
PIP_INSTALL_CMD = pip3 install
VIRTUALENV_NAME = venv

# Helper functions to display messagse
ECHO_BLUE = @echo "\033[33;34m $1\033[0m"
ECHO_RED = @echo "\033[33;31m $1\033[0m"

# The default server host local development
HOST ?= localhost:8000


virtualenv:
	virtualenv -p python3 --no-site-packages $(VIRTUALENV_NAME) #--always-copy

migrate:
	( \
		. $(VIRTUALENV_NAME)/bin/activate; \
		$(MANAGE_CMD) migrate; \
	)

superuser:
	( \
		. $(VIRTUALENV_NAME)/bin/activate; \
		$(MANAGE_CMD) createsuperuser; \
	)

runserver:
	( \
		. $(VIRTUALENV_NAME)/bin/activate; \
		$(MANAGE_CMD) runserver $(HOST); \
	)

update_fixtures:
	( \
		. $(VIRTUALENV_NAME)/bin/activate; \
		#$(MANAGE_CMD) clear_index --noinput; \
	)

messages:
	# Create the .po files used for i18n
	( \
		. $(VIRTUALENV_NAME)/bin/activate; \
		$(MANAGE_CMD) makemessages -l nl -l pl -l en; \
	)

update_static:
	# update static
	( \
		. $(VIRTUALENV_NAME)/bin/activate; \
		$(MANAGE_CMD) collectstatic; \
	)

compilemessages:
	# Compile the gettext files
	( \
		. $(VIRTUALENV_NAME)/bin/activate; \
		$(MANAGE_CMD) compilemessages; \
	)

coverage:
	( \
		. $(VIRTUALENV_NAME)/bin/activate; \
		coverage run manage.py test $(module) --noinput --failfast --verbosity=3; \
		coverage html; \
	)

clean:
	# Remove files not in source control
	find . -type f -name "*.pyc" -delete
	rm -rf nosetests.xml coverage.xml htmlcov *.egg-info *.pdf dist violations.txt

update_dev:
	$(call ECHO_BLUE,Installing Python requirements)
	@echo '------------------------------'
	( \
		. $(VIRTUALENV_NAME)/bin/activate; \
		 $(PIP_INSTALL_CMD) -r requirements/development.txt; \
	)

update_prod:
	$(call ECHO_BLUE,Installing Python requirements)
	@echo '------------------------------'
	( \
		. $(VIRTUALENV_NAME)/bin/activate; \
		 $(PIP_INSTALL_CMD) -r requirements/production.txt; \
	)

test:
# Run the test cases
	( \
		. $(VIRTUALENV_NAME)/bin/activate; \
		$(MANAGE_CMD) test $(module) --noinput --failfast --verbosity=3; \
	)

shell:
# Run a local shell for debugging
	( \
		. $(VIRTUALENV_NAME)/bin/activate; \
		$(MANAGE_CMD) shell; \
	)

robot_frontend:
# Run the test cases
	( \
		. $(VIRTUALENV_NAME)/bin/activate; \
		pybot tests/features/frontend/$(step); \
	)

robot_dashboard:
# Run the test cases
	( \
		. $(VIRTUALENV_NAME)/bin/activate; \
		pybot tests/features/dashboard/$(step); \
	)
