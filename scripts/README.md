### HOW TO USE
* Build docker image (run once)
   ```sh
   ./docker-create.sh
   ```

* Start docker container (run once. Need to rerun if docker container has been stopped)
   ```sh
   ./docker-start.sh
   ```

* Run test
   ```sh
   ./run-test.sh
   ```
   or setup a cron job
   ```sh
   $ crontab -e
   1 1 * * 6 cd /home/trungdt/debian-cross/build && ./scripts/run-test.sh
   ```