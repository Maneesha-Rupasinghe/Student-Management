# Generated by Django 4.2.20 on 2025-04-25 04:44

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0004_taskevent'),
    ]

    operations = [
        migrations.AddField(
            model_name='taskevent',
            name='priority',
            field=models.FloatField(default=1),
            preserve_default=False,
        ),
    ]
