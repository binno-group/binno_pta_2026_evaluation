FROM golang:1.26.5 AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
ARG TARGET=binno
RUN CGO_ENABLED=0 go build -o /out/app ./cmd/${TARGET}

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /out/app /app
USER 65532:65532
ENTRYPOINT ["/app"]
