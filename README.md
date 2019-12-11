# Swissknife

This orb helps make common operations in various CircleCI workflows easier. (#monorepo) Some of the smaller
useful commands are "fail if dirty", "run if modified", "run on branch". There are a few more
complicated commands such as "wait for workflow" and "wait for job" which have niche usecases.

Official Orb page: [https://circleci.com/orbs/registry/orb/roopakv/swissknife](https://circleci.com/orbs/registry/orb/roopakv/swissknife)

## Usage

Add swissknife to your Circle yml as follows


```
orbs:
  swissknife: roopakv/swissknife@0.12.0
```

Once you have defined the Orb you can use the following commands

### Fail if dirty

This can be used to fail a job if a number of steps result in git being dirty. Some examples
of where this can be useful

- Someone adds to package.json without using npm or yarn
- You use `go generate` and someone made changes to a file but forgot to run `go generate`

Look [here](https://circleci.com/orbs/registry/orb/roopakv/swissknife#commands-fail_if_dirty) for the
parameters this job accepts

### Run if modified

Run steps only certain files are modified. For example, run js tests only if js files are modified.

Note: This command ends the job if files are not modified.

Read [here](https://circleci.com/orbs/registry/orb/roopakv/swissknife#commands-run_if_modified) for usage.

### Wait for job

Circle doesnt allow you to run Job A after job B irrespective of job A's exit status. This command works around that.

Wrap a set of steps with this command and pass in the job it should run after and be rest assured that it will run the
jobs one by one.

[Here](https://circleci.com/orbs/registry/orb/roopakv/swissknife#commands-wait_for_job) for usage info.

### Wait for workflow

This lets you build a fake queue for a given branch and blocks workflows from actually running till previous workflows on
this branch have been completed.

Note: By blocking workflows we mean that the job simply sleeps till it is its turn to run. i.e. you will be using circle credits
to sleep this long (maybe use small containers?)

Look [here](https://circleci.com/orbs/registry/orb/roopakv/swissknife#commands-wait_for_workflow) for usage.

### Github Release

This lets you create a Github release to a specified repository using custom tags. This can be useful if you want to generate
releases on each master commit for instance.

Look [here](https://circleci.com/orbs/registry/orb/roopakv/swissknife#commands-publish_github_release) for usage.

## Contribution

Please open an issue for the functionality you wish to add. Lets make sure it will work / there is nothing else like it.

When adding a new command, either add a circle test that we can use during build OR add a script that we can run to test things.
