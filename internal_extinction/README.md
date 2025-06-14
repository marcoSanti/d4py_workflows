# Internal Extinction of Galaxies 

[This workflow](./int_ext_graph.py) has been developed to calculate the extinction within the galaxies, representing the dust extinction within the galaxies used in measuring the optical luminosity. The first PE, "ReadRaDec", read the coordinator data for 1051 galaxies in an input file. Then, these data are used in the second PE "GetVOTable" as arguments to make an HTTP request to the Virtual Observatory website  and get the VOTable as the response. Finally, these VOTable go into PE "FilterColumns"

See [Figure](./internal_extinction.jpg) representing this workflow.

## Requirements


Activate the conda python 3.10+ enviroment. If you had not created one, follow the [README instructions](https://github.com/StreamingFlow/d4py/tree/main).

```
conda activate d4py_env
```

To run the this workflow, first you need to install:
```shell
$ pip install requests
$ pip install astropy
``` 

## Important

If you run the workflow from a different directory, you only need to specify the path as <DIR1>.<DIR2>.<NAME_WORKFLOW> without the .py extension. However, if you are in the internal_extinction directory, then use <NAME_WORKFLOW>.py. Bellow there are two examples for clarity:

Example 1 - within article_sentiment directory:

```shell
dispel4py simple int_ext_graph.py -d '{"read" : [ {"input" : "coordinates.txt"} ]}'
```

Example 2 - other place (e.g. outside d4py_workflows directory):

```shell
dispel4py simple d4py_workflows.internal_extinction.int_ext_graph -d '{"read" : [ {"input" : "coordinates.txt"} ]}'
```

## Using Docker Container

Alternative you can follow [this instructions](https://github.com/StreamingFlow/d4py/tree/main#docker) to build a docker image and run dispel4py and this workflow within a docker container.

Once you are inside the docker container, you will have to clone this repository, and enter to the d4py_workflows directory. See bellow:
```
git clone https://github.com/StreamingFlow/d4py_workflows.git
cd d4py_workflows
```
Using our Docker  image, we can ensure that all the mappings described [bellow](https://github.com/StreamingFlow/d4py_workflows/tree/main/internal_extinction#run-the-workflow-with-different-mappings) work for this workflow.

## Known Issues

It seems that astropy 6.0.0 and python 3.10 has a problem with `astropy.io.votable import parse_single_table` and the `Logger`. See bellow: 

```
  File "<frozen importlib._bootstrap_external>", line 883, in exec_module
  File "<frozen importlib._bootstrap>", line 241, in _call_with_frames_removed
  File "/home/user/d4py_workflows/internal_extinction/int_ext_graph.py", line 38, in <module>
    from astropy.io.votable import parse_single_table
  File "/home/user/venv/lib/python3.10/site-packages/astropy/__init__.py", line 174, in <module>
    log = _init_log()
  File "/home/user/venv/lib/python3.10/site-packages/astropy/logger.py", line 113, in _init_log
    log._set_defaults()
AttributeError: 'Logger' object has no attribute '_set_defaults'
```

Fix:  Comment Line 113 of `XXXX/python3.10/site-packages/astropy/logger.py` --> `#log._set_defaults`. This should solve the issue.


## Run the workflow with different mappings

### Simple mapping

```shell
python -m dispel4py.new.processor simple int_ext_graph.py -d '{"read" : [ {"input" : "coordinates.txt"} ]}'
```

OR

```shell
dispel4py simple int_ext_graph.py -d '{"read" : [ {"input" : "coordinates.txt"} ]}'
```
The ‘coordinates.txt’ file is the workflow's input data with the coordinates of the galaxies.


### (Fixed) MPI mapping
```shell
mpiexec -n 10 dispel4py mpi int_ext_graph.py -d '{"read" : [ {"input" : "coordinates.txt"} ]}' -n 10
```
OR

```shell
mpiexec -n 10 --allow-run-as-root --oversubscribe dispel4py mpi int_ext_graph.py -d '{"read" : [ {"input" : "coordinates.txt"} ]}' -n 10
```
OR

```shell
mpiexec -n 10 python -m dispel4py.new.processor dispel4py.new.mpi_process int_ext_graph.py -d '{"read" : [ {"input" : "coordinates.txt"} ]}' -n 10
```
 Flag '-n' specify the number of processes. In the case of MPI mapping we need to indicate twice this '-n' flag.


### Multi mappings 

Remember, these mapping (multi, dyn_multi, dyn_auto_multi) do not seem to work properly in MacOS (M1 chip). We recommend in this case to use our [Docker image](https://github.com/StreamingFlow/d4py/tree/main) to create a container.


#### (Fixed) Multi mapping

```shell
python -m dispel4py.new.processor multi int_ext_graph.py -d '{"read" : [ {"input" : "coordinates.txt"} ]}' -n 10
```

OR

```shell
dispel4py multi int_ext_graph.py -d '{"read" : [ {"input" : "coordinates.txt"} ]}' -n 10
```

 Flag '-n' specify the number of processes.

#### Dynamic Multi mapping 
```shell
python -m dispel4py.new.processor dyn_multi int_ext_graph.py -d '{"read" : [ {"input" : "coordinates.txt"} ]}' -n 10
```
OR
```shell
dispel4py dyn_multi int_ext_graph.py -d '{"read" : [ {"input" : "coordinates.txt"} ]}' -n 10
```

#### Dynamic Multi Autoscaling mapping 
```shell
python -m dispel4py.new.processor dyn_auto_multi int_ext_graph.py -d '{"read" : [ {"input" : "coordinates.txt"} ]}' -n 10 -thr 10
```
OR
```shell
dispel4py dyn_auto_multi int_ext_graph.py -d '{"read" : [ {"input" : "coordinates.txt"} ]}' -n 10 -thr 10
```

### Redis mappings

Remember, you need to have installed both, redis server and redis client. 

#### (Fixed) Redis mapping

> Go to another terminal for following command line

```shell
redis-server
```

> Go back to previous terminal

```shell
python -m dispel4py.new.processor redis int_ext_graph.py -d '{"read" : [ {"input" : "coordinates.txt"} ]}' -ri localhost -n 10
```
OR 

```shell
dispel4py redis int_ext_graph.py -d '{"read" : [ {"input" : "coordinates.txt"} ]}' -ri localhost -n 10
```

#### Dynamic Redis mapping

> Go to another terminal for following command line

```shell
redis-server
```

> Go back to previous terminal

```shell
python -m dispel4py.new.processor dyn_redis int_ext_graph.py -d '{"read" : [ {"input" : "coordinates.txt"} ]}' -n 10
```
OR
```shell
dispel4py dyn_redis int_ext_graph.py -d '{"read" : [ {"input" : "coordinates.txt"} ]}' -n 10
```

#### Dynamic Redis Autoscaling mapping 
```shell
python -m dispel4py.new.processor dyn_auto_redis int_ext_graph.py -d '{"read" : [ {"input" : "coordinates.txt"} ]}' -n 10 -thr 200
```

OR
```shell
dispel4py dyn_auto_redis int_ext_graph.py -d '{"read" : [ {"input" : "coordinates.txt"} ]}' -n 20 -thr 200
``` 


#### Hybrid Redis mapping 
```shell
python -m dispel4py.new.processor hybrid_redis int_ext_graph.py -d '{"read" : [ {"input" : "coordinates.txt"} ]}' -n 10
```
OR
```shell
dispel4py hybrid_redis int_ext_graph.py -d '{"read" : [ {"input" : "coordinates.txt"} ]}' -n 10
```

## Running with a Script
(You might have to adapt those)

Check [run_int.sh](./run_int.sh); [run_init_moni.sh](./run_init_moni.sh); and [run_int_skew.sh](./run_int_skew.sh)
