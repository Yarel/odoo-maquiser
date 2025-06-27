from odoo import fields, models

class ResPartner(models.Model):
    _inherit = 'res.partner'
    
    partner_gid = fields.Char(
        string='Global ID',
        help='Global identifier for the partner',
        index=True
    )