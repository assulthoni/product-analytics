import random
from faker import Faker
import pandas as pd
import datetime

fake = Faker()
Faker.seed(42)
random.seed(42)

# Parameters
num_marketing_campaigns = 100
num_ads_exposure = 1000
num_website_events = 1000000
num_users = 1000
num_subscriptions = 253000

# num_marketing_campaigns = 10
# num_ads_exposure = 100
# num_website_events = 1000
# num_users = 10
# num_subscriptions = 253


# Generate Marketing Campaigns
def generate_marketing_campaigns(num):
    campaigns = []
    sources = ["Facebook", "Paid Search", "Google Ads", "Instagram", "Tiktok"]
    for _ in range(num):
        campaign_name = f"{random.choice(sources)} - {fake.name()}"
        spend = round(random.uniform(1000, 50000), 2)
        launch_date = fake.date_this_decade()
        end_date = fake.date_between(start_date=launch_date)
        campaigns.append((campaign_name, spend, launch_date, end_date))
    return campaigns

marketing_campaigns = generate_marketing_campaigns(num_marketing_campaigns)
marketing_campaigns_df = pd.DataFrame(marketing_campaigns, columns=["campaign_name", "spend", "launch_date", "end_date"])

# Generate User Data
def generate_users(num):
    users = []
    for _ in range(num):
        user_id = fake.uuid4()
        email = fake.email()
        name = fake.name()
        timestamp = fake.date_time_this_year()
        users.append((user_id, email, name, timestamp))
    return users

users = generate_users(num_users)
users_df = pd.DataFrame(users, columns=["user_id", "email", "name", "timestamp"])

# Generate Ads Exposure
def generate_ads_exposure(num, campaigns, users):
    ads = []
    for _ in range(num):
        campaign_name = random.choice(campaigns)[0]
        is_clicked = random.choice([True, False])
        timestamp = fake.date_time_this_year()
        duration = random.randint(1, 600)  # ad duration between 1 sec and 10 min
        email = random.choice(users)[1] if is_clicked else None
        ads.append((campaign_name, is_clicked, timestamp, duration, email))
    return ads

ads_exposure = generate_ads_exposure(num_ads_exposure, marketing_campaigns, users)
ads_exposure_df = pd.DataFrame(ads_exposure, columns=["campaign_name", "is_clicked", "timestamp", "duration", "email"])

# Generate Website Events
def generate_website_events(num, users):
    events = []
    for _ in range(num):
        user_id = random.choice(users)[0]
        event_name = random.choice(["page_view", "button_click", "form_submit", "link_click", "watch", "purchase"])
        if event_name == 'watch':
            path = f"/watch/{random.randint(1,50)}"
        elif event_name == 'purchase':
            path = 'subscribe'
        else:
            path = fake.uri_path()
        timestamp = fake.date_time_this_year()
        events.append((user_id, event_name, path, timestamp))
    return events

website_events = generate_website_events(num_website_events, users)
website_events_df = pd.DataFrame(website_events, columns=["user_id", "event_name", "path", "timestamp"])

# Generate Purchases
def generate_purchases(num, users):
    purchases = []
    for x in range(num):
        id = x + 1
        user_id = random.choice(users)[0]
        plan = random.choice(["basic", "premium", "pro"])
        amount = random.choice([10.00, 50.00, 99.99])
        timestamp = fake.date_time_this_year()
        purchases.append((id, user_id, plan, amount, timestamp))
    return purchases

purchases = generate_purchases(num_subscriptions, users)
purchases_df = pd.DataFrame(purchases, columns=["id","user_id", "plan", "amount", "timestamp"])

# Generate Subscriptions
def generate_subscriptions(num, users, purchases):
    subscriptions = []
    for x in range(num):
        user_id = purchases[x][1]
        start_date = purchases[x][4].date()
        end_date = (start_date + datetime.timedelta(days=30))
        purchase_id = purchases[x][0]
        subscriptions.append((user_id, start_date, end_date, purchase_id))
    return subscriptions

subscriptions = generate_subscriptions(num_subscriptions, users, purchases)
subscriptions_df = pd.DataFrame(subscriptions, columns=["user_id", "start_date", "end_date", "purchase_id"])

# Save DataFrames as CSV for database ingestion
# marketing_campaigns_df.to_csv('marketing_campaigns.csv', index=False)
# ads_exposure_df.to_csv('ads_exposure.csv', index=False)
website_events_df.to_csv('website_events.csv', index=False)
# users_df.to_csv('users.csv', index=False)
# purchases_df.to_csv('purchases.csv', index=False)
# subscriptions_df.to_csv('subscriptions.csv', index=False)

print("Data generation completed and saved to CSV files.")
