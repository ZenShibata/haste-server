const http = require("http");

http.get(`http://localhost:${process.env.PORT}`, res => {
    if (res.statusCode === 200) return process.exit(0);

    process.exit(1);
});

