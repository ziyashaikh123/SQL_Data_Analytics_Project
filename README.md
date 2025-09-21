# 🛒  Sales Analytics Project  

## ✨ Project Overview  
This project focuses on analyzing **retail sales, customer, and product data** using **MySQL (SQL)**.  
The goal is to extract **actionable business insights** that help in decision-making, including:  

📈 Sales trends over time  
🧑‍🤝‍🧑 Customer segmentation & spending behavior  
📦 Product & category performance  
📊 Key performance indicators (KPIs)  

It demonstrates advanced SQL techniques like **window functions, CTEs, and views** to solve real-world business problems.  

---

## 🗂️ Dataset Structure  
The project uses a **Star Schema**:  

- **`fact_sales`** → transactional sales data  
- **`dim_customers`** → customer details  
- **`dim_products`** → product attributes  

---

## 📊 Analysis Performed  

### 🔹 1. Change Over Time Trends  
✔ Sales by **Year**  
✔ Sales by **Month**  
✔ Combined **Year + Month** analysis  
✔ **Running totals** & **Moving averages**  

### 🔹 2. Performance Analysis  
✔ **Year-over-Year (YoY)** sales growth  
✔ Product performance vs **average sales**  
✔ Growth/decline detection using **LAG()**  

### 🔹 3. Part-to-Whole Analysis  
✔ Contribution of each **category** to total sales  
✔ Ranking categories by **revenue share**  

### 🔹 4. Data Segmentation  
📦 **Product Segmentation** (by price ranges):  
- Below 100  
- 100–500  
- 500–1000  
- Above 1000  

🧑‍🤝‍🧑 **Customer Segmentation** (based on spending & lifespan):  
- **VIP** → ≥ 12 months + spending > 5000  
- **Regular** → ≥ 12 months + spending ≤ 5000  
- **New** → lifespan < 12 months  

### 🔹 5. Customer Report (Final View)  
A consolidated **customer-level analytics report**:  
- Profile → name, age, age group, segment  
- Orders, total sales, products purchased, lifespan  
- KPIs → **recency, average order value, monthly spend**  

---

## 🛠️ Skills & Techniques Applied  
✅ SQL **Aggregations & Grouping**  
✅ **Window Functions** → `SUM() OVER`, `AVG() OVER`, `LAG()`  
✅ **CTEs (Common Table Expressions)**  
✅ **Views** for reporting  
✅ Analytics Approaches:  
   - Trend Analysis  
   - Part-to-Whole Analysis  
   - Performance Benchmarking  
   - Segmentation & Profiling  

---

## 🚀 Key Takeaways  
This project simulates **real-world retail analytics** and demonstrates how to:  

✔ Transform raw transactional data into **business insights**  
✔ Identify **customer patterns & behaviors**  
✔ Track **product & category performance**  
✔ Build a **ready-to-use report** for BI dashboards  

---

## 🔮 Next Steps  
📌 Add **data visualizations** using Tableau / Power BI / Python (Matplotlib, Seaborn).  
📌 Automate reporting pipelines for real-time analytics.  
📌 Extend with **predictive analytics** (e.g., customer churn, product demand).  

---

## 👩‍💻 Author  
**Aashiya Ziya Shaikh** ✨  
📍 Aspiring Data Analyst   
