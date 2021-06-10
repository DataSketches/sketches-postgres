-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--   http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing,
-- software distributed under the License is distributed on an
-- "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
-- KIND, either express or implied.  See the License for the
-- specific language governing permissions and limitations
-- under the License.

CREATE TYPE theta_sketch;

CREATE OR REPLACE FUNCTION theta_sketch_in(cstring) RETURNS theta_sketch
     AS '$libdir/datasketches', 'pg_sketch_in'
     LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION theta_sketch_out(theta_sketch) RETURNS cstring
     AS '$libdir/datasketches', 'pg_sketch_out'
     LANGUAGE C STRICT IMMUTABLE;

CREATE TYPE theta_sketch (
    INPUT = theta_sketch_in,
    OUTPUT = theta_sketch_out,
    STORAGE = EXTERNAL
);

CREATE CAST (bytea as theta_sketch) WITHOUT FUNCTION AS ASSIGNMENT;
CREATE CAST (theta_sketch as bytea) WITHOUT FUNCTION AS ASSIGNMENT;

CREATE OR REPLACE FUNCTION theta_sketch_add_item(internal, anyelement) RETURNS internal
    AS '$libdir/datasketches', 'pg_theta_sketch_add_item'
    LANGUAGE C IMMUTABLE;

CREATE OR REPLACE FUNCTION theta_sketch_add_item(internal, anyelement, int) RETURNS internal
    AS '$libdir/datasketches', 'pg_theta_sketch_add_item'
    LANGUAGE C IMMUTABLE;

CREATE OR REPLACE FUNCTION theta_sketch_add_item(internal, anyelement, int, real) RETURNS internal
    AS '$libdir/datasketches', 'pg_theta_sketch_add_item'
    LANGUAGE C IMMUTABLE;

CREATE OR REPLACE FUNCTION theta_sketch_get_estimate(theta_sketch) RETURNS double precision
    AS '$libdir/datasketches', 'pg_theta_sketch_get_estimate'
    LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION theta_sketch_get_estimate_and_bounds(theta_sketch, int DEFAULT 3) RETURNS double precision[]
    AS '$libdir/datasketches', 'pg_theta_sketch_get_estimate_and_bounds'
    LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION theta_sketch_from_internal(internal) RETURNS theta_sketch
    AS '$libdir/datasketches', 'pg_theta_sketch_from_internal'
    LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION theta_sketch_get_estimate_from_internal(internal) RETURNS double precision
    AS '$libdir/datasketches', 'pg_theta_sketch_get_estimate_from_internal'
    LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION theta_sketch_to_string(theta_sketch) RETURNS TEXT
    AS '$libdir/datasketches', 'pg_theta_sketch_to_string'
    LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION theta_sketch_union_agg(internal, theta_sketch) RETURNS internal
    AS '$libdir/datasketches', 'pg_theta_sketch_union_agg'
    LANGUAGE C IMMUTABLE;

CREATE OR REPLACE FUNCTION theta_sketch_union_agg(internal, theta_sketch, int) RETURNS internal
    AS '$libdir/datasketches', 'pg_theta_sketch_union_agg'
    LANGUAGE C IMMUTABLE;

CREATE OR REPLACE FUNCTION theta_sketch_intersection_agg(internal, theta_sketch) RETURNS internal
    AS '$libdir/datasketches', 'pg_theta_sketch_intersection_agg'
    LANGUAGE C IMMUTABLE;    

CREATE OR REPLACE FUNCTION theta_union_get_result(internal) RETURNS theta_sketch
    AS '$libdir/datasketches', 'pg_theta_union_get_result'
    LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION theta_intersection_get_result(internal) RETURNS theta_sketch
    AS '$libdir/datasketches', 'pg_theta_intersection_get_result'
    LANGUAGE C STRICT IMMUTABLE;    

CREATE AGGREGATE theta_sketch_distinct(anyelement) (
    sfunc = theta_sketch_add_item,
    stype = internal,
    finalfunc = theta_sketch_get_estimate_from_internal
);

CREATE AGGREGATE theta_sketch_distinct(anyelement, int) (
    sfunc = theta_sketch_add_item,
    stype = internal,
    finalfunc = theta_sketch_get_estimate_from_internal
);

CREATE AGGREGATE theta_sketch_build(anyelement) (
    sfunc = theta_sketch_add_item,
    stype = internal,
    finalfunc = theta_sketch_from_internal
);

CREATE AGGREGATE theta_sketch_build(anyelement, int) (
    sfunc = theta_sketch_add_item,
    stype = internal,
    finalfunc = theta_sketch_from_internal
);

CREATE AGGREGATE theta_sketch_build(anyelement, int, real) (
    sfunc = theta_sketch_add_item,
    stype = internal,
    finalfunc = theta_sketch_from_internal
);

CREATE AGGREGATE theta_sketch_union(theta_sketch) (
    sfunc = theta_sketch_union_agg,
    stype = internal,
    finalfunc = theta_union_get_result
);

CREATE AGGREGATE theta_sketch_union(theta_sketch, int) (
    sfunc = theta_sketch_union_agg,
    stype = internal,
    finalfunc = theta_union_get_result
);

CREATE AGGREGATE theta_sketch_intersection(theta_sketch) (
    sfunc = theta_sketch_intersection_agg,
    stype = internal,
    finalfunc = theta_intersection_get_result
);

CREATE OR REPLACE FUNCTION theta_sketch_union(theta_sketch, theta_sketch) RETURNS theta_sketch
    AS '$libdir/datasketches', 'pg_theta_sketch_union'
    LANGUAGE C IMMUTABLE;

CREATE OR REPLACE FUNCTION theta_sketch_union(theta_sketch, theta_sketch, int) RETURNS theta_sketch
    AS '$libdir/datasketches', 'pg_theta_sketch_union'
    LANGUAGE C IMMUTABLE;

CREATE OR REPLACE FUNCTION theta_sketch_intersection(theta_sketch, theta_sketch) RETURNS theta_sketch
    AS '$libdir/datasketches', 'pg_theta_sketch_intersection'
    LANGUAGE C IMMUTABLE;

CREATE OR REPLACE FUNCTION theta_sketch_a_not_b(theta_sketch, theta_sketch) RETURNS theta_sketch
    AS '$libdir/datasketches', 'pg_theta_sketch_a_not_b'
    LANGUAGE C STRICT IMMUTABLE;
