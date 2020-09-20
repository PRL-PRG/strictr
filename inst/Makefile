include Makevars

DATA_DIR := data

# for RUN_DIR we need absolute path because parallel will run
# things relatively from inidividual working dirs
RUN_DIR := $(CURDIR)/run

JOBS          ?= 64
PACKAGES_FILE ?= $(DATA_DIR)/packages-corpus.txt
TIMEOUT       ?= 1d

RUNR_DIR           := $(R_PROJECT_BASE_DIR)/runr
RUNR_TASKS_DIR     := $(RUNR_DIR)/inst/tasks

ON_EACH_PACKAGE := $(MAKE) on-each-package
MERGE_CSV := $(RUNR_DIR)/inst/merge-csv.R
MERGE_FST := $(RUNR_DIR)/inst/merge-fst.R

# tasks output directory
PACKAGE_COVERAGE_DIR      := $(RUN_DIR)/package-coverage
PACKAGE_EVAL_CALLS_DIR    := $(RUN_DIR)/package-eval-calls
PACKAGE_EVALS_DIR         := $(RUN_DIR)/package-evals
PACKAGE_METADATA_DIR      := $(RUN_DIR)/package-metadata
PACKAGE_RUNNABLE_CODE_DIR := $(RUN_DIR)/package-runnable-code

# tasks result
PACKAGE_COVERAGE_CSV      := $(PACKAGE_COVERAGE_DIR)/coverage.csv
PACKAGE_EVAL_CALLS_FST    := $(PACKAGE_EVAL_CALLS_DIR)/calls.fst
PACKAGE_EVALS_CSV         := $(PACKAGE_EVALS_DIR)/package-evals.csv
PACKAGE_FUNCTIONS_CSV     := $(PACKAGE_METADATA_DIR)/functions.csv
PACKAGE_METADATA_CSV      := $(PACKAGE_METADATA_DIR)/metadata.csv
PACKAGE_REVDEPS_CSV       := $(PACKAGE_METADATA_DIR)/revdeps.csv
PACKAGE_RUNNABLE_CODE_CSV := $(PACKAGE_RUNNABLE_CODE_DIR)/runnable-code.csv
PACKAGE_SLOC_CSV          := $(PACKAGE_METADATA_DIR)/sloc.csv

##
## EXTRACT RUNNABLE CODE
##
$(PACKAGE_RUNNABLE_CODE_CSV): export OUTPUT_DIR=$(@D)
$(PACKAGE_RUNNABLE_CODE_CSV):
	$(ON_EACH_PACKAGE) TASK=$(RUNR_TASKS_DIR)/package-runnable-code-eval.R
	$(MERGE_CSV) "$(OUTPUT_DIR)" $(@F) runnable-code-metadata.csv

##
## EVAL TRACING on CRAN
##
$(PACKAGE_EVAL_CALLS_FST): $(PACKAGE_RUNNABLE_CODE_CSV)
$(PACKAGE_EVAL_CALLS_FST): export OUTPUT_DIR=$(@D)
$(PACKAGE_EVAL_CALLS_FST): export START_XVFB=1
$(PACKAGE_EVAL_CALLS_FST):
	$(ON_EACH_PACKAGE) TASK=$(RUNR_TASKS_DIR)/run-extracted-code.R ARGS="$(dir $(PACKAGE_RUNNABLE_CODE_CSV))/{1/}"
	$(MERGE_FST) "$(OUTPUT_DIR)" $(@F)

##
## COVERAGE
##
$(PACKAGE_COVERAGE_CSV): export OUTPUT_DIR=$(@D)
$(PACKAGE_COVERAGE_CSV): export START_XVFB=1
$(PACKAGE_COVERAGE_CSV): export RUNR_PACKAGE_COVERAGE_TYPE=all
$(PACKAGE_COVERAGE_CSV):
	$(ON_EACH_PACKAGE) TASK=$(RUNR_TASKS_DIR)/package-coverage.R

##
## METADATA
##
$(PACKAGE_FUNCTIONS_CSV) $(PACKAGE_METADATA_CSV) $(PACKAGE_REVDEPS_CSV) $(PACKAGE_SLOC_CSV): export OUTPUT_DIR=$(@D)
$(PACKAGE_FUNCTIONS_CSV) $(PACKAGE_METADATA_CSV) $(PACKAGE_REVDEPS_CSV) $(PACKAGE_SLOC_CSV):
	$(ON_EACH_PACKAGE) TASK=$(RUNR_TASKS_DIR)/package-metadata.R
	$(MERGE_CSV) "$(OUTPUT_DIR)" functions.csv metadata.csv revdeps.csv sloc.csv

##
## STATIC EVALS
##
$(PACKAGE_EVALS_CSV): export OUTPUT_DIR=$(@D)
$(PACKAGE_EVALS_CSV):
	$(ON_EACH_PACKAGE) TASK=$(RUNR_TASKS_DIR)/package-evals-statis.R

.PHONY: \
  data \
  on-each-package \
  package-coverage \
  package-eval-calls \
  package-evals \
  package-metadata \
  package-runnable-code

data: $(PACKAGE_COVERAGE_CSV) \
      $(PACKAGE_METADATA_CSV) \
      $(PACKAGE_FUNCTIONS_CSV) \
      $(PACKAGE_REVDEPS_CSV)
	cp $^ $(DATA_DIR)

package-coverage: $(PACKAGE_COVERAGE_CSV)
package-eval-calls: $(PACKAGE_EVAL_CALLS_FST)
package-evals: $(PACKAGE_EVALS_CSV)
package-metadata: $(PACKAGE_METADATA_CSV)
package-runnable-code: $(PACKAGE_RUNNABLE_CODE_CSV)

on-each-package:
	@[ "$(TASK)" ] || ( echo "*** Undefined TASK"; exit 1 )
	@[ -x "$(TASK)" ] || ( echo "*** $(TASK): no such file"; exit 1 )
	@[ "$(OUTPUT_DIR)" ] || ( echo "*** Undefined OUTPUT_DIR"; exit 1 )

	-mkdir -p "$(OUTPUT_DIR)"
	-if [ -n "$(START_XVFB)" ]; then  \
     nohup Xvfb :6 -screen 0 1280x1024x24 >/dev/null 2>&1 & \
     export DISPLAY=:6; \
  fi; \
  export R_TESTS=""; \
  export R_BROWSER="false"; \
  export R_PDFVIEWER="false"; \
  export R_BATCH=1; \
  export NOT_CRAN="true"; \
	echo "X11 display=$$DISPLAY"; \
  parallel \
    -a $(PACKAGES_FILE) \
    --bar \
    --env PATH \
    --jobs $(JOBS) \
    --results "$(OUTPUT_DIR)/parallel.csv" \
    --tagstring "$(notdir $(TASK)) - {/}" \
    --timeout $(TIMEOUT) \
    --workdir "$(OUTPUT_DIR)/{/}/" \
    $(RUNR_DIR)/inst/run-task.sh \
      $(TASK) "$(PACKAGES_SRC_DIR)/{1/}" $(ARGS)

