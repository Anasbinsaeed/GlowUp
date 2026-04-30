package com.example.cuteapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.net.Uri
import java.io.File
import es.antonborri.home_widget.HomeWidgetPlugin

class GlowupHomeWidget : AppWidgetProvider() {

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
            val views = RemoteViews(context.packageName, R.layout.glowup_home_widget)

            val widgetData = HomeWidgetPlugin.getData(context)

            // Tap to open app
            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

            // Load the rendered image created by renderFlutterWidget
            val imagePath = widgetData.getString("home_widget", null)
            if (imagePath != null) {
                val uri = Uri.fromFile(File(imagePath))
                views.setImageViewUri(R.id.widget_image, uri)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}