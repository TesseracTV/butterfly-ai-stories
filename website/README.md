# Butterfly AI Stories – Landing Page

**Domain:** [butterflyaistories.com](https://butterflyaistories.com/)

Single-page landing site for the app. Host on **AWS S3 + CloudFront** (much cheaper than GoDaddy hosting). The domain can stay registered at GoDaddy; you only point its DNS to AWS.

**Screenshots:** The `screenshots/` folder contains copies of the app screenshots. Upload the entire `website/` folder so these images are available.

## Deploy to AWS and use your domain

1. **S3:** Create a bucket (e.g. `butterflyaistories.com`), upload all files from this folder. You can leave the bucket private if you use CloudFront.
2. **CloudFront:** Create a distribution with the S3 bucket as origin. Set **Default Root Object** to `index.html`. This gives you HTTPS and a CloudFront URL (e.g. `d1234abcd.cloudfront.net`).
3. **HTTPS for butterflyaistories.com:** In **AWS Certificate Manager (ACM)** (us-east-1), request a certificate for `butterflyaistories.com` and `www.butterflyaistories.com`. Validate via DNS. Then in CloudFront, add the domain as an alternate domain name (CNAME) and attach the certificate.
4. **Point the domain to AWS:** In **GoDaddy** (or wherever the domain is registered), open DNS settings for butterflyaistories.com. Add or edit:
   - **A record** for `@` (or root): set to the CloudFront distribution’s domain (e.g. `d1234abcd.cloudfront.net`). GoDaddy may use “CNAME flattening” so you enter the CloudFront hostname in the A record target.
   - **CNAME** for `www`: target your CloudFront domain (e.g. `d1234abcd.cloudfront.net`).
   - Remove any old A/CNAME records that pointed to GoDaddy hosting.

After DNS propagates (often 5–30 minutes), https://butterflyaistories.com/ will serve your site from AWS.

## Links on the page (already set)

- **App Store** – Butterfly AI Stories (id 6739846656)
- **Privacy Policy** – TermsFeed URL
- **Terms** – Local `terms.html`
- **Support** – support@lifetracker.life
