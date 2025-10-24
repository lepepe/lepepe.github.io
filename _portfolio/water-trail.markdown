---
layout: portfolio
title: "Water Trail"
slug: water-trail
categories: web
hide: false
---

As an avid kayaker and developer, I'm always looking for ways to combine my passions. That's why I created the **Kayak Trip Tracker**, a very simple Streamlit application to help me organize and visualize my kayak camping trips.

<div align="center">
  <img 
    width="536" 
    height="363" 
    alt="logo" 
    src="/assets/images/portfolio/water-trail/logo.png"
  />
</div>

In this post, I'll walk you through the features of the app and how you can run it on your own machine using Docker.

## Features

The Kayak Trip Tracker is designed to be a one-stop shop for all my kayak trip planning needs. Here are some of the key features:

*   **Interactive Map:** The app displays an interactive map with the kayak route and waypoints for each trip. I used the `folium` library to create the map, which allows for easy zooming, panning, and even measuring distances.
*   **Trip Management:** All trip data is stored in a SQLite database, making it easy to manage and update. The app allows you to select from a list of existing trips and view the corresponding route and waypoints.
*   **Add New Trips:** I've included a form in the sidebar that allows you to add new trips to the database. You can specify the trip name, description, and even the route and waypoints in JSON format.

## How it Works

The app is built with Python and the Streamlit library. Here's a quick overview of the code:

The `app.py` file is the heart of the application. It uses Streamlit to create the user interface and `folium` to generate the map. The app connects to a SQLite database to fetch and store trip data.

Here's a snippet of the code that creates the map:

```python
# Create map
# Recalculate center based on selected trip
if river_path:
    avg_lat = sum(p[0] for p in river_path) / len(river_path)
    avg_lon = sum(p[1] for p in river_path) / len(river_path)
    map_center = [avg_lat, avg_lon]
else:
    map_center = [30.28, -82.92]  # Default center

suwannee_map = folium.Map(location=map_center, zoom_start=10, tiles="OpenStreetMap")

# Add markers
for p in points:
    folium.Marker(
        location=p["coords"],
        popup=p["name"],
        tooltip=p["name"],
        icon=folium.Icon(color=p["color"], icon=p["icon"], prefix="fa"),
    ).add_to(suwannee_map)

# Add River Route (PolyLine)
if river_path:
    folium.PolyLine(
        river_path,
        color="#00FFFF",
        weight=6,
        opacity=0.9,
        popup=f"{selected_trip_name} Route",
    ).add_to(suwannee_map)
```

The `database.py` file contains all the functions for interacting with the SQLite database. It includes functions for creating the database tables, adding new trips, and fetching trip data.

## How to Run with Docker

The easiest way to run the Kayak Trip Tracker is with Docker. I've included a `docker-compose.yml` file that makes it easy to build and run the app in a container.

1.  Build the Docker image:
    ```
    docker-compose build
    ```
2.  Run the Docker container:
    ```
    docker-compose up
    ```

Once the container is running, you can access the app in your web browser at `http://localhost:8501`.

## Final Thoughts

This project was such a fun way to blend my love for kayaking and outdoors with my passion for coding. I’m really looking forward to using the Water Trail app to plan future adventures, and I hope it inspires you to build your own creative projects with Streamlit!
