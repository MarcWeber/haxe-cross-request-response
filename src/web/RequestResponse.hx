package web;
import web.Response;
import web.Request;

typedef RequestResponse = {
  response: ResponseState,
  request: RequestState // cannot use > Request here !??
};
