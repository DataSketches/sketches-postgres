/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

#include "kll_float_sketch_c_adapter.h"
#include "allocator.h"

#include <sstream>

#include <kll_sketch.hpp>

typedef datasketches::kll_sketch<float, std::less<float>, datasketches::serde<float>, palloc_allocator<float>> kll_float_sketch;

void* kll_float_sketch_new(unsigned k) {
  try {
    return new (palloc(sizeof(kll_float_sketch))) kll_float_sketch(k);
  } catch (std::exception& e) {
    elog(ERROR, e.what());
  }
}

void kll_float_sketch_delete(void* sketchptr) {
  try {
    static_cast<kll_float_sketch*>(sketchptr)->~kll_float_sketch();
    pfree(sketchptr);
  } catch (std::exception& e) {
    elog(ERROR, e.what());
  }
}

void kll_float_sketch_update(void* sketchptr, float value) {
  try {
    static_cast<kll_float_sketch*>(sketchptr)->update(value);
  } catch (std::exception& e) {
    elog(ERROR, e.what());
  }
}

void kll_float_sketch_merge(void* sketchptr1, const void* sketchptr2) {
  try {
    static_cast<kll_float_sketch*>(sketchptr1)->merge(*static_cast<const kll_float_sketch*>(sketchptr2));
  } catch (std::exception& e) {
    elog(ERROR, e.what());
  }
}

double kll_float_sketch_get_rank(const void* sketchptr, float value) {
  try {
    return static_cast<const kll_float_sketch*>(sketchptr)->get_rank(value);
  } catch (std::exception& e) {
    elog(ERROR, e.what());
  }
}

float kll_float_sketch_get_quantile(const void* sketchptr, double rank) {
  try {
    return static_cast<const kll_float_sketch*>(sketchptr)->get_quantile(rank);
  } catch (std::exception& e) {
    elog(ERROR, e.what());
  }
}

uint64 kll_float_sketch_get_n(const void* sketchptr) {
  try {
    return static_cast<const kll_float_sketch*>(sketchptr)->get_n();
  } catch (std::exception& e) {
    elog(ERROR, e.what());
  }
}

void kll_float_sketch_to_string(const void* sketchptr, char* buffer, unsigned length) {
  try {
    std::stringstream s;
    static_cast<const kll_float_sketch*>(sketchptr)->to_stream(s);
    snprintf(buffer, length, s.str().c_str());
  } catch (std::exception& e) {
    elog(ERROR, e.what());
  }
}

void* kll_float_sketch_serialize(const void* sketchptr) {
  try {
    auto data = static_cast<const kll_float_sketch*>(sketchptr)->serialize(VARHDRSZ);
    bytea* buffer = (bytea*) data.first.release();
    const size_t length = data.second;
    SET_VARSIZE(buffer, length);
    return buffer;
  } catch (std::exception& e) {
    elog(ERROR, e.what());
  }
}

void* kll_float_sketch_deserialize(const char* buffer, unsigned length) {
  try {
    return new (palloc(sizeof(kll_float_sketch))) kll_float_sketch(kll_float_sketch::deserialize(buffer, length));
  } catch (std::exception& e) {
    elog(ERROR, e.what());
  }
}

unsigned kll_float_sketch_get_serialized_size_bytes(const void* sketchptr) {
  try {
    return static_cast<const kll_float_sketch*>(sketchptr)->get_serialized_size_bytes();
  } catch (std::exception& e) {
    elog(ERROR, e.what());
  }
}

Datum* kll_float_sketch_get_pmf(const void* sketchptr, const float* split_points, unsigned num_split_points) {
  try {
    auto ptr = static_cast<const kll_float_sketch*>(sketchptr)->get_PMF(split_points, num_split_points);
    Datum* pmf = (Datum*) palloc(sizeof(Datum) * (num_split_points + 1));
    for (unsigned i = 0; i < num_split_points + 1; i++) {
      pmf[i] = Float8GetDatum(ptr[i]);
    }
    return pmf;
  } catch (std::exception& e) {
    elog(ERROR, e.what());
  }
}

Datum* kll_float_sketch_get_quantiles(const void* sketchptr, const double* fractions, unsigned num_fractions) {
  try {
    auto ptr = static_cast<const kll_float_sketch*>(sketchptr)->get_quantiles(fractions, num_fractions);
    Datum* quantiles = (Datum*) palloc(sizeof(Datum) * num_fractions);
    for (unsigned i = 0; i < num_fractions; i++) {
      quantiles[i] = Float4GetDatum(ptr[i]);
    }
    return quantiles;
  } catch (std::exception& e) {
    elog(ERROR, e.what());
  }
}
