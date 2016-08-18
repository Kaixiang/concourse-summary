#![feature(plugin, custom_derive)]
#![plugin(serde_macros)]

extern crate hyper;
extern crate iron;
extern crate serde;
extern crate serde_json;

use iron::prelude::*;
use iron::status;
use hyper::*;


#[derive(Deserialize, Debug)]
struct Request {
  name: string,
  url: string,
  paused: bool,
}

fn main() {
  let client = Client::new();
  let mut res = client.get("https://ci.concourse.ci/api/v1/pipelines").send().unwrap();

  assert_eq!(res.status, hyper::Ok);
  let mut s = String::new();
  res.read_to_string(&mut s).unwrap();
  println!("{}", s);


  // fn hello_world(_: &mut Request) -> IronResult<Response> {
    // Ok(Response::with((status::Ok, "Hello World!")))
  // }

  // Iron::new(hello_world).http("localhost:3000").unwrap();
  // println!("On 3000");
}

