set -e

# https://stackoverflow.com/questions/39296472/how-to-check-if-an-environment-variable-exists-and-get-its-value

if [[ -z "${DOCKER_HOST}" ]]; then
  echo "DOCKER_HOST not set, exiting. Run `source env_vars.sh`"
  exit 1;
fi

if [ ! -f raspberrypi/.raspberrypi.env ]; then
    echo
    echo "please create raspberrypi/.raspberrypi.env";
    echo
    exit 1;
fi


REGISTRY=localhost:5000

echo "Building docker images for backend and frontend"

echo "Building backend image"

if [[ -z "${VERSION}" ]]; then
  echo "No backend version set, using git short hash"
  VERSION=$(git rev-parse --short HEAD);
  echo $VERSION
else
  echo "Backend version is $VERSION"
fi

echo "Building and tagging backend container\n"

docker \
    -l "debug" \
    build \
    --platform linux/arm64 \
    -t $REGISTRY/backend:$VERSION \
    -f backend/Dockerfile \
    ./backend/

echo "Building and tagging frontend container"

docker build \
    # --build-arg BACKEND_API_URL=$BACKEND_API_URL \
    -t $REGISTRY/nginx:$VERSION \
    -f nginx/prod/Dockerfile \
    .

export CI_REGISTRY_IMAGE=$REGISTRY
export CI_COMMIT_SHORT_SHA=$VERSION

echo "Checking environment variables for swarm"

if [[ -z "${POSTGRES_PASSWORD}" ]]; then
  echo "WARNING: POSTGRES_PASSWORD not set, exiting."
fi

docker stack deploy -c raspberrypi/stack.yml my-stack
