import ballerina/http;

public type Country record {
    string name;
    string continent;
    int population;
    decimal gdp;
    float area;
};

service / on new http:Listener(8080) {
    // The `countries` resource function returns:
    // - `json`: A JSON array containing the top 10 countries based on GDP per capita.
    // - `http:InternalServerError`: An HTTP 500 error response if there is a failure in processing the request.
    resource function get countries() returns json|http:InternalServerError {
        do {
            // Creating an HTTP client to connect to the server.
            http:Client countriesClient = check new ("http://localhost:9090");

            // Sending a GET request to the "/countries" endpoint and retrieving an array of `Country` records.
            Country[] countries = check countriesClient->/countries;

            // Using a query expression to process the list of countries and generate a summary.
            json topCountries =
                from var {name, continent, population, area, gdp} in countries
            where population >= 100000000 && area >= 1000000.0 // Filtering countries with a population >= 100M and area >= 1M sq km.
            let decimal gdpPerCapita = (gdp / population).round(2) // Calculating and rounding GDP per capita to 2 decimal places.
            order by gdpPerCapita descending // Sorting the results by GDP per capita in descending order.
            limit 10 // Limiting the results to the top 10 countries.
            select {name, continent, gdpPerCapita}; // Selecting the country name, continent, and GDP per capita.
            return topCountries;
        } on fail var err {
            return <http:InternalServerError>{
                body: {
                    "error": "Failed to retrieve countries from the backend service",
                    "message": err.message()
                }
            };
        }
    }
}
