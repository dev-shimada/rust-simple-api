use actix_web::{web, App, HttpResponse, HttpServer};

#[actix_web::main]
async fn main() {
    let server = HttpServer::new(|| {
        App::new()
            .route("/", web::get().to(index))
    });
    
    println!("Serving on http://0.0.0.0:3000...");
    server.bind("0.0.0.0:3000").expect("error binding server to address").run().await.expect("error running server");
}

async fn index() -> HttpResponse {
    HttpResponse::Ok().content_type("text/html").body("Hello, world!")
}
