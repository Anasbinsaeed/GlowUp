package com.example.cuteapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import es.antonborri.home_widget.HomeWidgetPlugin

class GlowupDashboardWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.glowup_dashboard_widget)

            // Tap to open app
            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.dash_greeting, pendingIntent)

            // Header
            val name = widgetData.getString("home_name", null)
            val greeting = if (name != null) "Glowup ✨  $name" else "Glowup ✨"
            views.setTextViewText(R.id.dash_greeting, greeting)

            val now = java.util.Calendar.getInstance()
            val dateStr = android.text.format.DateFormat.format("EEE, MMM d", now).toString()
            views.setTextViewText(R.id.dash_date, dateStr)

            // Reminders
            val r1 = widgetData.getString("reminder_1", null)
            val r2 = widgetData.getString("reminder_2", null)
            if (r1 != null) {
                views.setTextViewText(R.id.dash_reminder_1, r1)
            } else {
                views.setTextViewText(R.id.dash_reminder_1, "No reminders today 🎉")
            }
            if (r2 != null) {
                views.setTextViewText(R.id.dash_reminder_2, r2)
                views.setViewVisibility(R.id.dash_reminder_2, android.view.View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.dash_reminder_2, android.view.View.GONE)
            }

            // Habits
            val done = widgetData.getInt("habits_done", 0)
            val total = widgetData.getInt("habits_total", 0)
            val progress = if (total > 0) (done * 100 / total) else 0
            views.setTextViewText(R.id.dash_habits_count, "$done/$total")
            views.setProgressBar(R.id.dash_habits_progress, 100, progress, false)

            // Flight
            val hasFlightData = widgetData.getBoolean("flight_has_data", false)
            val flightRoute = widgetData.getString("flight_route", null)
            val flightCountdown = widgetData.getString("flight_countdown", null)
            if (hasFlightData && flightRoute != null) {
                views.setTextViewText(R.id.dash_flight_route, flightRoute)
                views.setTextViewText(R.id.dash_flight_countdown, flightCountdown ?: "")
            } else {
                views.setTextViewText(R.id.dash_flight_route, "No flights ✈️")
                views.setTextViewText(R.id.dash_flight_countdown, "")
            }

            // Fitness
            val walkKm = widgetData.getString("fitness_walk_km", "0.0")
            val activities = widgetData.getInt("fitness_activities", 0)
            views.setTextViewText(R.id.dash_fitness_walk, "$walkKm km")
            views.setTextViewText(R.id.dash_fitness_activities, "$activities activities")

            // Grocery
            val groceryCount = widgetData.getInt("grocery_count", 0)
            val groceryItem1 = widgetData.getString("grocery_1", null)
            views.setTextViewText(R.id.dash_grocery_count, "$groceryCount item${if (groceryCount == 1) "" else "s"}")
            views.setTextViewText(R.id.dash_grocery_item, groceryItem1 ?: "")

            // Subscriptions
            val subTotal = widgetData.getString("sub_monthly_total", null)
            val currency = widgetData.getString("sub_currency", "€")
            val subNext = widgetData.getString("sub_next_name", null)
            if (subTotal != null) {
                views.setTextViewText(R.id.dash_sub_total, "$currency$subTotal/mo")
            } else {
                views.setTextViewText(R.id.dash_sub_total, "—")
            }
            views.setTextViewText(R.id.dash_sub_next, subNext ?: "")

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
