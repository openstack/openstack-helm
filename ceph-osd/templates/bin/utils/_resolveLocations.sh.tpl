#!/bin/bash

{{/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

set -ex

if [[ "${STORAGE_LOCATION}" ]]; then
  STORAGE_LOCATION=$(ls ${STORAGE_LOCATION})
  if [[ `echo "${STORAGE_LOCATION}" | wc -w` -ge 2 ]]; then
    echo "ERROR- Multiple locations found: ${STORAGE_LOCATION}"
    exit 1
  fi
fi

if [[ "${BLOCK_DB}" ]]; then
  BLOCK_DB=$(ls ${BLOCK_DB})
  if [[ `echo "${BLOCK_DB}" | wc -w` -ge 2 ]]; then
    echo "ERROR- Multiple locations found: ${BLOCK_DB}"
    exit 1
  fi
fi

if [[ "${BLOCK_WAL}" ]]; then
  BLOCK_WAL=$(ls ${BLOCK_WAL})
  if [[ `echo "${BLOCK_WAL}" | wc -w` -ge 2 ]]; then
    echo "ERROR- Multiple locations found: ${BLOCK_WAL}"
    exit 1
  fi
fi
