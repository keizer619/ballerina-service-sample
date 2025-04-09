import ballerina/data.csv;
import ballerina/http;
import ballerina/io;
import ballerina/log;

public type Country record {
    string name;
    string capital;
    string continent;
    int population;
    float area;
    string languages;
    string currency;
    float gdp;
};

service / on new http:Listener(9090) {
    resource function get countries(http:Request req) returns Country[]|http:InternalServerError {

        string|error userAgent = req.getHeader("User-Agent");
        if userAgent is string && userAgent == "ballerina" {
            log:printInfo("Request received from User-Agent: ballerina");
        }

        // Read the CSV content as a string
        string|error csvContent = io:fileReadString("countries.csv");
        if csvContent is error {
            log:printError("Error reading CSV file", err = csvContent.message());
            return <http:InternalServerError>{body: csvContent.message()};
        }

        Country[]|error countries = csv:parseString(csvContent);
        if countries is error {
            log:printError("Error parsing CSV content", err = countries.message());
            return <http:InternalServerError>{body: countries.message()};
        }
        return countries;
    }
}
