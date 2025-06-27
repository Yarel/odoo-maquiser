from odoo import models, fields

class PartnerCategory(models.Model):
    _inherit = 'res.partner.category'

    textil_related = fields.Boolean(
        string='Para uso textil',
        default=False,
        help="Indica si esta categoría es específica para textiles"
    )