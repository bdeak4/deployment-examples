export const handler = (event) => {
  const request = event.Records[0].cf.request;

  const host = request.headers.host.find((item) => item.key === "Host").value;
  request.uri = "/" + host.split(".")[0] + request.uri;

  if (request.uri.endsWith("/")) {
    request.uri += "index.html";
  }

  return request;
};
