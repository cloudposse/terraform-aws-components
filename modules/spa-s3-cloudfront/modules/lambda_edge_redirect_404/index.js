'use strict';

const http = require('https');

const page404 = '404.html';

exports.handler = async (event, context, callback) => {
    const cf = event.Records[0].cf;
    const request = cf.request;
    const response = cf.response;
    const statusCode = response.status;

    // Only replace 403 and 404 requests typically received
    // when loading a page for a SPA that uses client-side routing
    const doReplace = request.method === 'GET'
                    && (statusCode == '403' || statusCode == '404');

    const result = doReplace
        ? await generateResponseAndLog(cf, request, page404)
        : response;

    response.status = result.status;
    response.headers = {...response.headers, ...result.headers};
    response.body = result.body;

    callback(null, response);
};

async function generateResponseAndLog(cf, request, page404) {
    const forwardedHost = request.headers['x-forwarded-host'];
    const domain = forwardedHost && forwardedHost.length > 0
        ? forwardedHost[0].value
        : cf.config.distributionDomainName;
    const indexPath = `/${page404}`;

    const response = await generateResponse(domain, indexPath);
    console.log('response: ' + JSON.stringify(response));
    return response;
}

async function generateResponse(domain, path){
    try {
        // Load HTML index from the CloudFront cache
        const s3Response = await httpGet({ hostname: domain, path: path });

        const headers = s3Response.headers ||
            {
                'content-type': [{ value: 'text/html;charset=UTF-8' }]
            };

        return {
            status: '200',
            statusDescription: 'OK',
            headers: wrapAndFilterHeaders(headers),
            body: s3Response.body
        };
    } catch (error) {
        return {
            status: '500',
            headers:{
                'content-type': [{ value: 'text/plain' }]
            },
            body: 'An error occurred loading the page'
        };
    }
}

function httpGet(params) {
    return new Promise((resolve, reject) => {
        http.get(params, (resp) => {
            let result = {
                headers: resp.headers,
                body: ''
            };
            resp.on('data', (chunk) => { result.body += chunk; });
            resp.on('end', () => { resolve(result); });
        }).on('error', (err) => {
            console.log(`Couldn't fetch ${params.hostname}${params.path} : ${err.message}`);
            reject(err, null);
        });
    });
}

// Cloudfront requires header values to be wrapped in an array
function wrapAndFilterHeaders(headers){
    const allowedHeaders = [
        "content-type",
        "content-length",
        "date",
        "last-modified",
        "etag",
        "cache-control",
        "accept-ranges",
        "server",
        "age"
    ];

    const responseHeaders = {};

    if(!headers){
        return responseHeaders;
    }

    for(var propName in headers) {
        // only include allowed headers
        if(allowedHeaders.includes(propName.toLowerCase())){
            var header = headers[propName];

            if (Array.isArray(header)){
                // assume already 'wrapped' format
                responseHeaders[propName] = header;
            } else {
                // fix to required format
                responseHeaders[propName] = [{ value: header }];
            }
        }

    }

    return responseHeaders;
}
